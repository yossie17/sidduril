import SwiftUI
import UIKit

/// A lightweight UIViewRepresentable wrapper around UITextView tuned for
/// long Hebrew prayers: forces RTL semantic, sets paragraph style and
/// uses an attributed string for better typography and performance.
struct PrayerTextView: UIViewRepresentable {
    let text: String
    let fontName: String = "FrankRuhlLibre-Regular"
    let fontSize: CGFloat

    init(text: String, fontSize: CGFloat = 20) {
        self.text = text
        self.fontSize = fontSize
    }

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.isSelectable = true
        // Let the UITextView handle its own scrolling for best performance with large texts
        tv.isScrollEnabled = true
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.adjustsFontForContentSizeCategory = true
        tv.dataDetectorTypes = []

        // Force RTL at UIKit level for text shaping and punctuation
        tv.semanticContentAttribute = .forceRightToLeft
        tv.textAlignment = .right

        // Initial text setup
        context.coordinator.updateIfNeeded(text: text, textView: tv)
        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.updateIfNeeded(text: text, textView: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator {
        var parent: PrayerTextView
        private var lastText: String?
        private var lastAttributed: NSAttributedString?

        init(_ parent: PrayerTextView) {
            self.parent = parent
        }

        func updateIfNeeded(text: String, textView: UITextView) {
            // Avoid expensive attributed string creation if nothing changed
            if lastText == text, let attr = lastAttributed {
                if textView.attributedText != attr {
                    textView.attributedText = attr
                }
                return
            }

            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .right
            paragraph.lineSpacing = 6
            paragraph.paragraphSpacing = 8

            let regularFont: UIFont
            let boldFont: UIFont
            
            if let f = UIFont(name: parent.fontName, size: parent.fontSize) {
                regularFont = f
                // Try to get bold variant, fallback to system bold
                if let bf = UIFont(name: "FrankRuhlLibre-Bold", size: parent.fontSize) {
                    boldFont = bf
                } else {
                    boldFont = UIFont.boldSystemFont(ofSize: parent.fontSize)
                }
            } else {
                regularFont = UIFont.systemFont(ofSize: parent.fontSize)
                boldFont = UIFont.boldSystemFont(ofSize: parent.fontSize)
            }

            let regularAttrs: [NSAttributedString.Key: Any] = [
                .font: regularFont,
                .paragraphStyle: paragraph,
                .foregroundColor: UIColor.label
            ]
            
            let boldAttrs: [NSAttributedString.Key: Any] = [
                .font: boldFont,
                .paragraphStyle: paragraph,
                .foregroundColor: UIColor.label
            ]

            // Create attributed string with bold titles
            let attrString = NSMutableAttributedString()
            let lines = text.components(separatedBy: .newlines)
            
            for (index, line) in lines.enumerated() {
                let isTitle = isLineATitle(line)
                let attrs = isTitle ? boldAttrs : regularAttrs
                
                attrString.append(NSAttributedString(string: line, attributes: attrs))
                
                // Add newline except for last line
                if index < lines.count - 1 {
                    attrString.append(NSAttributedString(string: "\n", attributes: regularAttrs))
                }
            }
            
            lastText = text
            lastAttributed = attrString
            textView.attributedText = attrString
        }
        
        private func isLineATitle(_ line: String) -> Bool {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Empty lines are not titles
            if trimmed.isEmpty {
                return false
            }
            
            // Lines with vowel marks (nikkud) are not titles
            let nikudRange: ClosedRange<Unicode.Scalar> = "\u{0591}"..."\u{05C7}"
            let nikudCharacterSet = CharacterSet(charactersIn: nikudRange)
            if trimmed.rangeOfCharacter(from: nikudCharacterSet) != nil {
                return false
            }
            
            // Short lines without nikkud are likely titles
            // Typical title length is less than 30 characters
            if trimmed.count < 30 {
                return true
            }
            
            return false
        }
    }

    private func updateTextView(_ tv: UITextView) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        paragraph.lineSpacing = 6
        paragraph.paragraphSpacing = 8

        let font: UIFont
        if let f = UIFont(name: fontName, size: fontSize) {
            font = f
        } else {
            font = UIFont.systemFont(ofSize: fontSize)
        }

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraph,
            .foregroundColor: UIColor.label
        ]

        // Preserve existing attributes when possible
        let attrString = NSAttributedString(string: text, attributes: attrs)
        if tv.attributedText != attrString {
            tv.attributedText = attrString
        }
    }
}
