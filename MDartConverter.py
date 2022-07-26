import os, shutil
from datetime import datetime

class File :
    def __init__(self, folder: str, filename: str, rootFolder: str = "./mlib", convertFolder: str = "./lib") :
        self.folder = folder
        self.filename = filename
        self.mtime = self.getMTime()

        self.rootFolder = rootFolder
        self.convertFolder = convertFolder

    def getMTime(self) :
        return int(os.path.getmtime(self.getFilePath()))

    def isModified(self) :
        if (self.mtime != self.getMTime()) :
            self.mtime = self.getMTime()
            return True
        return False

    def isFileExist(self):
        return os.path.exists(self.getFilePath())

    def getFilePath(self) :
        return os.path.join(self.folder, self.filename)

    def getConvertFilePath(self) :
        return self.getFilePath().replace(self.rootFolder, self.convertFolder, 1).replace(".mdart", ".dart", 1)

    def getConvertFolderPath(self):
        return self.folder.replace(self.rootFolder, self.convertFolder, 1)

    def delete(self):
        print(self.getConvertFilePath())
        os.remove(self.getConvertFilePath())

    def __findTarget(self, indent, index, code) :
        target = None

        for idx, c in enumerate(code[index + 1::], index + 1) :
            ind, text = int(c[0]), str(c[1])

            if ind <= indent and text != "" :
                target = idx - 1 if code[idx - 1][1] == "" else idx
                break
            elif text == "" and code[idx - 1][1] == "":
                target = idx - 1
                break

        return target

    def convertToDart(self) :
        copyPath = self.getFilePath() + ".copy"

        shutil.copy(self.getFilePath(), copyPath)

        with open(copyPath, "r") as mdart:
            code = mdart.readlines()
            code = [[len(line.rstrip()) - len(line.strip()), line.rstrip()] for line in code]
            
            shortMap = {
                "setState :": {
                    "open": "setState(() {",
                    "close": "});",
                },
                "::": {
                    "open": "{",
                    "close": "}",
                },
                "::,": {
                    "open": "{",
                    "close": "},",
                },
                "..": {
                    "open": "(",
                    "close": ")",
                },
                "..,": {
                    "open": "(",
                    "close": "),",
                },
                "..;": {
                    "open": "(",
                    "close": ");",
                },
                ",,,": {
                    "open": "[",
                    "close": "],",
                },
                ",,;": {
                    "open": "[",
                    "close": "];",
                },
                ",,": {
                    "open": "[",
                    "close": "]",
                },
            }

            run = True
            while run :
                run = False

                copyCode = code.copy()
                for index, data in enumerate(copyCode) :
                    indent, text = int(data[0]), str(data[1])

                    for key, short in shortMap.items() :
                        if text.endswith(key) and not text.strip().startswith("//") :
                            run = True

                            target = self.__findTarget(indent, index, copyCode)
                            target = target if target != None else len(copyCode)

                            code[index][1] = code[index][1][:len(key) * -1] + short["open"]
                            code.insert(target, [indent, (indent * " ") + short["close"]])

                            break

                    if run:
                        break
            
            code = [line[1] + "\n" for line in code]

            with open(self.getConvertFilePath(), "w") as dart:
                dart.writelines(code)

        os.remove(copyPath)

        return

    def __repr__(self) -> str:
        return f"{self.filename[0:5]}"

class MDartConverter :
    def __init__(self, debug = False, autoDelete = False):
        self.trackFiles: "list[File]" = []
        self.debug = debug

    def log(self, title, text):
        if self.debug :
            print(f"\r[{self.__class__.__name__}:{title}] : {text}", flush=True, end="")

    def scanFile(self, rootPath) -> "list[File]":
        # self.log("Scan","Start scan...")

        for (folderPath, _, fileNames) in os.walk(rootPath) :
            for file in fileNames :
                if str(file).endswith(".mdart") :
                    f = File(folderPath, file)
                    
                    if not any(filter(lambda track: f.getFilePath() == track.getFilePath(), self.trackFiles)) :
                        self.trackFiles.append(f)

        return self.trackFiles

    def updateFileFolder(self) :
        flagRemoveFiles = []

        for file in self.trackFiles :
            if not file.isFileExist() :
                flagRemoveFiles.append(file)
                continue

            os.makedirs(file.getConvertFolderPath(), exist_ok=True)

        [self.trackFiles.remove(file) for file in flagRemoveFiles]
        [file.delete() for file in flagRemoveFiles]
        del flagRemoveFiles

    def start(self, rootPath: str = "./mlib") :
        self.log("Main", "Start tracking...\n")
        
        while True:
            self.scanFile(rootPath)
            self.updateFileFolder()
            for file in self.trackFiles :
                if file.isFileExist() and file.isModified() :
                    self.log(f"Convert | {datetime.now().strftime('%H:%M:%S')} | {len(self.trackFiles)}", f"Convert {file.filename} to {file.filename.replace('.mdart', '.dart', 1)}")
                    file.convertToDart()


converter = MDartConverter(debug=True, autoDelete=True)
converter.start(rootPath = "./mlib")

