/*
 * Copyright (c) 2018 Confetti Interactive Inc.
 *
 * This file is part of The-Forge
 * (see https://github.com/ConfettiFX/The-Forge).
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
*/

#ifdef __APPLE__

#import <Foundation/Foundation.h>

#include "../Interfaces/IFileSystem.h"
#include "../Interfaces/ILogManager.h"
#include "../Interfaces/IOperatingSystem.h"
#include "../Interfaces/IMemoryManager.h"

#include <unistd.h>
#include <limits.h>  // for UINT_MAX
#include <sys/stat.h>  // for mkdir
#include <sys/errno.h> // for errno
#include <dirent.h>

#define RESOURCE_DIR "Shaders/OSXMetal"

const char* pszRoots[FSR_Count] =
{
	RESOURCE_DIR "/Binary/",			// FSR_BinShaders
	RESOURCE_DIR "/",					// FSR_SrcShaders
	RESOURCE_DIR "/Binary/",			// FSR_BinShaders_Common
	RESOURCE_DIR "/",					// FSR_SrcShaders_Common
	"Textures/",						// FSR_Textures
	"Meshes/",							// FSR_Meshes
	"Fonts/",							// FSR_Builtin_Fonts
	"GPUCfg/",							// FSR_GpuConfig
	"Animation/",						// FSR_Animation
	"",									// FSR_OtherFiles
};

FileHandle _openFile(const char* filename, const char* flags)
{
	FILE* fp = fopen(filename, flags);
	return fp;
}

void _closeFile(FileHandle handle)
{
	fclose((::FILE*)handle);
}

void _flushFile(FileHandle handle)
{
	fflush((::FILE*)handle);
}

size_t _readFile(void *buffer, size_t byteCount, FileHandle handle)
{
	return fread(buffer, byteCount, 1, (::FILE*)handle);
}

bool _seekFile(FileHandle handle, long offset, int origin)
{
	return fseek((::FILE*)handle, offset, origin) == 0;
}

long _tellFile(FileHandle handle)
{
	return ftell((::FILE*)handle);
}

size_t _writeFile(const void *buffer, size_t byteCount, FileHandle handle)
{
	return fwrite(buffer, byteCount, 1, (::FILE*)handle);
}

size_t _getFileLastModifiedTime(const char* _fileName)
{
	struct stat fileInfo;

	if (!stat(_fileName, &fileInfo))
	{
		return (size_t)fileInfo.st_mtime;
	}
	else
	{
		// return an impossible large mod time as the file doesn't exist
		return ~0;
	}
}

tinystl::string _getCurrentDir()
{
	char cwd[256]="";
	getcwd(cwd, sizeof(cwd));
	tinystl::string str(cwd);
	return str;
}

tinystl::string _getExePath()
{
	const char* exeDir = [[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] cStringUsingEncoding:NSUTF8StringEncoding];
	tinystl::string str(exeDir);
	return str;
}

tinystl::string _getAppPrefsDir(const char *org, const char *app)
{
	const char * rawUserPath = [[[[NSFileManager defaultManager] homeDirectoryForCurrentUser] absoluteString] UTF8String];
	const char * path;
	path = strstr(rawUserPath,"/Users/");
	return tinystl::string(path) + tinystl::string("Library/") + tinystl::string(org) + tinystl::string("/") + tinystl::string(app);
}

tinystl::string _getUserDocumentsDir()
{
	const char * rawUserPath = [[[[NSFileManager defaultManager] homeDirectoryForCurrentUser] absoluteString] UTF8String];
	const char * path;
	path = strstr(rawUserPath,"/Users/");
	return tinystl::string(path);
}

void _setCurrentDir(const char* path)
{
	chdir(path);
}

void _getFilesWithExtension(const char* dir, const char* ext, tinystl::vector<tinystl::string>& filesOut)
{
	tinystl::string path = FileSystem::GetNativePath(FileSystem::AddTrailingSlash(dir));
	DIR* pDir = opendir(dir);
	if(!pDir)
	{
		LOGWARNINGF("Could not open directory: %s", dir);
		return;
	}
	
	// recursively search the directory for files with given extension
	dirent* entry = NULL;
	while((entry = readdir(pDir)) != NULL)
	{
		if(FileSystem::GetExtension(entry->d_name) == ext)
		{
			filesOut.push_back(path + entry->d_name);
		}
	}
}

#endif // __APPLE__
