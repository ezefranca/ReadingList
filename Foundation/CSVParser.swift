import Foundation
import CHCSVParser

protocol CSVParserDelegate {
    func headersRead(_ headers: [String]) -> Bool
    func lineParseSuccess(_ values: [String: String])
    func lineParseError()
    func completion()
}

class CSVParser: NSObject, CHCSVParserDelegate {

    // CHCSVParserDelegate is informed of each read field. This wrapper is intended to create a simpler CSV Parser
    // which can response to completed lines, by the header names.
    private let parser: CHCSVParser!
    
    init(csvFileUrl: URL) {
        parser = CHCSVParser(contentsOfCSVURL: csvFileUrl)
        parser.sanitizesFields = true
        parser.recognizesBackslashesAsEscapes = true
        parser.trimsWhitespace = true
        parser.recognizesComments = true
        super.init()
        parser.delegate = self
    }
    
    var delegate: CSVParserDelegate?
    
    func begin() { parser.parse() }
    func stop() { parser.cancelParsing() }
    
    private var isFirstRow = true
    private var currentRowIsErrored = false
    private var currentRow = [String: String]()
    private var headersByFieldIndex = [Int: String]()
    
    func parser(_ parser: CHCSVParser!, didBeginLine recordNumber: UInt) {
        currentRow.removeAll(keepingCapacity: true)
        currentRowIsErrored = false
    }
    
    func parser(_ parser: CHCSVParser!, didReadField field: String!, at fieldIndex: Int) {
        guard !isFirstRow else { headersByFieldIndex[fieldIndex] = field; return }
        guard let currentHeader = headersByFieldIndex[fieldIndex] else { currentRowIsErrored = true; return }
        if let fieldValue = field.trimming().nilIfWhitespace() {
            currentRow[currentHeader] = fieldValue
        }
    }
    
    func parser(_ parser: CHCSVParser!, didEndLine recordNumber: UInt) {
        guard !isFirstRow else {
            if delegate?.headersRead(headersByFieldIndex.map{$0.value}) == false {
                stop()
            }
            isFirstRow = false
            return
        }
        guard !currentRowIsErrored else { delegate?.lineParseError(); return }

        delegate?.lineParseSuccess(currentRow)
    }
    
    func parserDidEndDocument(_ parser: CHCSVParser!) {
        delegate?.completion()
    }
}
