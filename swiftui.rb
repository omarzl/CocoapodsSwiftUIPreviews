# frozen_string_literal: true

require 'set'

module Pod
  class Podfile
      attr_reader :swiftui_previews_enabled
  end
  
  class Installer
    class Analyzer
      alias original_generate_pod_targets generate_pod_targets

      def generate_pod_targets(resolver_specs_by_target, target_inspections)
        targets = original_generate_pod_targets(resolver_specs_by_target, target_inspections)
        return targets unless podfile.swiftui_previews_enabled
        
        start_time = Time.now
        pods_to_modify = Set.new
        targets.each do |target|
          next unless target.should_enable_swiftui_previews
          pods_to_modify << target
          pods_to_modify += target.recursive_dependent_targets
        end
        pods_to_modify.each { |pod| pod.enable_swiftui_previews }
        puts "SwiftUI setup #{(Time.now.to_f - start_time.to_f).to_i}s"
        targets
      end
    end
  end

  class PodTarget

    attr_reader :swiftui_previews_enabled

    # Inspired in: https://github.com/microsoft/cocoapods-pod-linkage/blob/main/lib/cocoapods-pod-linkage/patched_analyzer.rb
    def should_enable_swiftui_previews
      # Enabled only for development pods
      return unless sandbox.local?(pod_name)
      # If it is already a dynamic framework we will return true so the
      # linker search paths are modified too
      return true if @build_type == Pod::BuildType.dynamic_framework

      chunk_size = 512
      file_accessors.any? do |fa|
        fa.spec.library_specification? &&
          fa.source_files.any? do |source|
            next if source.extname != '.swift'

            begin
              file = File.new(source)
              data = file.read(chunk_size)
              # Source files can be empty
              next if data.nil?
              # Validates if file imports SwiftUI in the first chunk
              next unless data.include?('import SwiftUI')

              validation = ->(data) { data.include?('PreviewProvider') }
              break true if validation.call(data)

              # Continues reading the file to validate if it contains a
              # Preview Provider
              while (new_data = file.read(chunk_size))
                data += new_data
                is_valid = true if validation.call(data)
              end
              break true if is_valid
            ensure
              file.close
            end
            false
          end
      end
    end

    def enable_swiftui_previews
      @swiftui_previews_enabled = true
      @build_type = Pod::BuildType.dynamic_framework
    end
  end

  class Target
    class BuildSettings::PodTargetSettings
        
      alias ld_runpath_search_paths_original ld_runpath_search_paths
      alias other_ldflags_original other_ldflags

      # This workaround is required for transitive dependencies since SwiftUI Previews
      # isn't looking for the framework in the right path.
      # See: https://github.com/CocoaPods/CocoaPods/issues/9275#issuecomment-576766934
      def ld_runpath_search_paths
        return ld_runpath_search_paths_original unless target.swiftui_previews_enabled
        (ld_runpath_search_paths_original || []) + framework_search_paths
      end

      # Inspired in: https://github.com/CocoaPods/CocoaPods/blob/master/lib/cocoapods/target/build_settings.rb#L380
      def other_ldflags
        return other_ldflags_original unless target.swiftui_previews_enabled
        new_flags = other_ldflags_original.dup
        dependent_targets_to_link.each do |dep|
          dep.framework_paths.each do |_key, fwk_paths|
            fwk_paths.each do |fwk_path|
              name = File.basename(fwk_path.source_path, '.*')
              new_flags << '-framework' << %("#{name}") unless frameworks.include?(name)
            end
          end
        end
        new_flags
      end
    end
  end
end
