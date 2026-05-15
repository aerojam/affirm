import Foundation

enum AppError: Error {
	case noAffirmationsFound
}

enum Style {
	static let yellow = "\u{001B}[33m"
	static let bold = "\u{001B}[1m"
	static let reset = "\u{001B}[0m"
}

let helpText = """

\(Style.bold)OVERVIEW:\(Style.reset) Affirm – Ranní dávka disciplíny pro Swift vývojáře.

\(Style.bold)USAGE:\(Style.reset) affirm [options]

\(Style.bold)OPTIONS:\(Style.reset)
  \(Style.yellow)-h, --help\(Style.reset)           		   Zobrazí tuto nápovědu.
  \(Style.yellow)-a, --add Text nové afirmace\(Style.reset)     Přidá novou afirmaci.

\(Style.bold)FILES:\(Style.reset)
  ~/Library/Application Support/Affirm/affirm.txt
  Soubor s vašimi afirmacemi. Nemůže-li aplikace soubor najít, vytvoří ho sama.
  Každý řádek jedna afirmace. Můžete si doplnit vlastní afirmace.

"""

func getFileUrl() throws -> URL {
    let fileManager = FileManager.default
    let appSupport = try fileManager.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )
    return appSupport.appendingPathComponent("Affirm/affirm.txt")
}

func ensureFileExist(at fileURL: URL) throws {
    let fileManager = FileManager.default
    let folderURL = fileURL.deletingLastPathComponent()
    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
    if !fileManager.fileExists(atPath: fileURL.path) {
        let initialContent = "Napište si svoje afirmace do souboru \(fileURL)\n"
        let data = initialContent.data(using: .utf8)
        let success = fileManager.createFile(atPath: fileURL.path, contents: data)
        if !success {
            print("Nepodařilo se vytvořit soubor \(fileURL.path)")
        }
    }
}

func loadAffirmations(from url: URL) throws -> [String] {
    try String(contentsOf: url, encoding: .utf8).components(separatedBy: .newlines).filter { !$0.isEmpty }
}

func showRandom(from affirmations: [String]) throws {
    guard let randomAffirm = affirmations.randomElement() else {
        throw AppError.noAffirmationsFound
    }
    print("\(Style.yellow)\(Style.bold)\(randomAffirm)\(Style.reset)")
}

func addAffirmation(to fileURL: URL, text: String) throws {
    try ensureFileExist(at: fileURL)
    let fileHandle = try FileHandle(forWritingTo: fileURL)
    defer {
        try? fileHandle.close()
    }
    if let data = (text + "\n").data(using: .utf8) {
        try fileHandle.seekToEnd()
        try fileHandle.write(contentsOf: data)
    }
}

do {
    let fileURL = try getFileUrl()
    try ensureFileExist(at: fileURL)
    if CommandLine.arguments.contains("-h") || CommandLine.arguments.contains("--help") {
        print(helpText)
        exit(0)
    }
    if CommandLine.arguments.contains("-a") || CommandLine.arguments.contains("--add") {
        let args = CommandLine.arguments
        if args.count >= 3 {
            let affirmText = CommandLine.arguments[2...].joined(separator: " ")
            try addAffirmation(to: fileURL, text: affirmText)
            print("Afirmace byla přidána.")
            exit(0)
        } else {
            print("Nemohl jsem přidat žádnou afirmaci.\n\n")
            print(helpText)
            exit(1)
        }
    }
    let affirmations = try loadAffirmations(from: fileURL)
    try showRandom(from: affirmations)
} catch AppError.noAffirmationsFound {
    print("Chyba: Soubor s afirmacemi je prázdný.")
} catch {
    print("Něco se nepovedlo: \(error.localizedDescription)")
}
