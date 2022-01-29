import Files
import ArgumentParser

for file in try Folder(path: ".").files {
    print(file.name)
}

// @main
// struct Gen: 
