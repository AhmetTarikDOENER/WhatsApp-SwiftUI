import Foundation

extension Date {
    var dayOrTimeRepresentation: String {
        let calender = Calendar.current
        let dateFormatter = DateFormatter()
        
        if calender.isDateInToday(self) {
            dateFormatter.dateFormat = "h:mm a"
            let formattedDate = dateFormatter.string(from: self)
            
            return formattedDate
        } else if calender.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = "MM/dd/yy"
            
            return dateFormatter.string(from: self)
        }
    }
}
