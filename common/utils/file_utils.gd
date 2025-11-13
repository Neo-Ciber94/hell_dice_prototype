class_name FileUtils

static func read_files(dir_path: String, pattern: String = "", recursive: bool = false) -> PackedStringArray:
	assert(DirAccess.dir_exists_absolute(dir_path), "Directory '%s' does not exists" % dir_path);
	
	if not dir_path.ends_with("/"):
		dir_path += "/"
	
	var file_paths: PackedStringArray = []
	var dir_access = DirAccess.open(dir_path)

	if dir_access == null:
		push_error("Failed to open directory: %s" % dir_path)
		return PackedStringArray()
		
	dir_access.list_dir_begin()
	var path: String = dir_access.get_next()
	
	while path != "":
		if dir_access.current_is_dir():
			if recursive:
				var result = read_files(dir_path + path, pattern, recursive)
				file_paths.append_array(result)
			else:
				continue;
			
		if path.match(pattern):
			var file_path = dir_path + path
			file_paths.push_back(file_path)
		
		path = dir_access.get_next()
	
	dir_access.list_dir_end()
	return file_paths;
