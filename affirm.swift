import Foundation

enum AppError: Error {
	case missingFolder
	case noAffirmationsFound(path: String)
}

enum Style {
	static let yellow = "\u{001B}[33m"
	static let bold = "\u{001B}[1m"
	static let reset = "\u{001B}[0m"
}

let fileManager = FileManager.default
var path = ""

let helpText = """
\(Style.bold)OVERVIEW:\(Style.reset) Affirm – Ranní dávka disciplíny pro Swift vývojáře.

\(Style.bold)USAGE:\(Style.reset) affirm [options]

\(Style.bold)OPTIONS:\(Style.reset)
  \(Style.yellow)-h, --help\(Style.reset)		Zobrazí tuto nápovědu.

\(Style.bold)FILES:\(Style.reset)
  ~/Library/Application Support/Affirm/affirm.txt
  Soubor s vašimi afirmacemi. Nemůže-li aplikace soubor najít, vytvořte si ho.
  Každý řádek jedna afirmace.
"""

if CommandLine.arguments.contains("-h") || CommandLine.arguments.contains("--help") {
    print(helpText)
    exit(0)
}

do {
    guard let appSupportUrl = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { throw AppError.missingFolder }
    let myAppFolder = appSupportUrl.appendingPathComponent("Affirm")
    try fileManager.createDirectory(at: myAppFolder, withIntermediateDirectories: true)
    path = myAppFolder.appendingPathComponent("affirm.txt").path
    if !fileManager.fileExists(atPath: path) {
        let initialContent = "Napište si svoje afirmace do souboru \(path)\n"
        let data = initialContent.data(using: .utf8)
        fileManager.createFile(atPath: path, contents: data)
    }
    let content = try String(contentsOfFile: path, encoding: .utf8)
    let affirmations = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
    guard let randomAffirm = affirmations.randomElement() else { throw AppError.noAffirmationsFound(path: path) }
    print("\(Style.yellow)\(Style.bold)\(randomAffirm)\(Style.reset)")
} catch AppError.noAffirmationsFound(let path) {
    print("Chyba: Soubor s afirmacemi je prázdný. Napište si je sami do \(path).")
} catch AppError.missingFolder {
    print("Kritická chyba: Nepodařilo se najít systémovou složku pro data.")
} catch {
    print("Chyba při čtení souboru: \(error.localizedDescription)")
}