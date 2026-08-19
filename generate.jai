#run,stallable {
	set_build_options_dc(.{do_output=false});

    #if OS == {
        case .WINDOWS;
            libDirectory := "windows";
        case;
            #assert false;
    }

	options := get_build_options();

	if !generate_bindings() {
		compiler_set_workspace_status(.FAILED);
		return;
	}
}

generate_bindings :: () -> bool {
	outputFilename: string;
	libDirectory: string;
    opts: Generate_Bindings_Options;
    {
        using opts;

        strip_flags = 0;

        #if OS == {
            case .WINDOWS;
                outputFilename = "windows.jai";
                libDirectory = "windows";

                array_add(*source_files, "./include/hidapi_winapi.h");
                // array_add(*path_fragments_to_treat_as_non_system_paths, "guiddef.h");
                // array_add(*system_types_to_include, "GUID", "_GUID");

            case;
                array_add(*source_files, "./include/hidapi.h");

                assert(false);
        }

		log_stripped_declarations = true;
		generate_library_declarations = true;
        generate_compile_time_struct_checks = true;

        array_add(*library_search_paths,  libDirectory);
        array_add(*libraries,      .{filename="hidapi"});
        array_add(*extra_clang_arguments, "-x", "c++", "-DWIN32_LEAN_AND_MEAN");
	}

    return generate_bindings(opts, outputFilename);
}

LIB_BASE_NAME :: "hidapi";

#scope_file

#import "Basic";
#import "Compiler";
#import "BuildCpp";
#import "Check";
#import "Bindings_Generator";
#import "File";
