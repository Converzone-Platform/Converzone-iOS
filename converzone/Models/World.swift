//
//  Earth
//  converzone
//
//  Created by Goga Barabadze on 07.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import Foundation

let countries_africa = [
    "Algeria", "Angola", "Benin", "Botswana", "Burkina Faso", "Burundi", "Cabo Verde", "Cameroon",
    "Central African Republic", "Chad", "Comoros", "Democratic Republic of the Congo", "Republic of the Congo", "Côte d’Ivoire", "Djibouti", "Egypt",
    "Equatorial Guinea", "Eritrea", "Eswatini", "Ethiopia", "Gabon", "Gambia", "Ghana", "Guinea",
    "Guinea-Bissau", "Kenya", "Lesotho", "Liberia", "Libya", "Madagascar", "Malawi", "Mali",
    "Mauritania", "Mauritius", "Morocco", "Mozambique", "Namibia", "Niger", "Nigeria", "Rwanda",
    "Sao Tome and Principe", "Senegal", "Seychelles", "Sierra Leone", "Somalia", "South Africa", "South Sudan", "Sudan",
    "Tanzania", "Togo", "Tunisia", "Uganda", "Zambia", "Zimbabwe"
]

let countries_asia = [
    "Afghanistan", "Armenia", "Azerbaijan", "Bahrain", "Bangladesh", "Bhutan", "Brunei", "Cambodia",
    "China", "Georgia", "India", "Indonesia", "Iran", "Iraq", "Israel",
    "Japan", "Jordan", "Kazakhstan", "Kuwait", "Kyrgyzstan", "Laos", "Lebanon", "Malaysia",
    "Maldives", "Mongolia", "Myanmar", "Nepal", "North Korea", "Oman", "Pakistan", "Palestine",
    "Philippines", "Qatar", "Russia", "Saudi Arabia", "Singapore", "South Korea", "Sri Lanka", "Syria",
    "Taiwan", "Tajikistan", "Thailand", "Timor-Leste", "Turkey", "Turkmenistan", "United Arab Emirates", "Uzbekistan",
    "Vietnam", "Yemen"
]

let countries_australia_and_oceania = [
    "Australia", "Fiji", "Kiribati", "Marshall Islands", "Micronesia", "Nauru", "New Zealand", "Palau", "Papua New Guinea", "Samoa",
    "Solomon Islands", "Tonga", "Tuvalu", "Vanuatu"
]

let countries_europe = [
    "Albania", "Andorra", "Armenia", "Austria", "Azerbaijan", "Belarus", "Belgium", "Bosnia and Herzegovina",
    "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France",
    "Georgia", "Germany", "Greece", "Hungary", "Iceland", "Ireland", "Italy", "Kazakhstan",
    "Kosovo", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "Republic of Macedonia", "Malta", "Moldova",
    "Monaco", "Montenegro", "Netherlands", "Norway", "Republic of Poland", "Portugal", "Romania", "Russia",
    "San Marino", "Serbia", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Turkey",
    "Ukraine", "United Kingdom", "Vatican City"
]

let countries_north_america = [
    "Antigua and Barbuda", "Bahamas", "Barbados", "Belize", "Canada", "Costa Rica", "Cuba", "Dominica",
    "Dominican Republic", "El Salvador", "Grenada", "Guatemala", "Haiti", "Honduras", "Jamaica", "Mexico",
    "Nicaragua", "Panama", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Trinidad and Tobago", "United States of America"
]

let countries_south_america = [
    "Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Ecuador", "Guyana", "Paraguay",
    "Peru", "Suriname", "Uruguay", "Venezuela"
]

let all_languages = [
    "Abaza", "Abenaki", "Abkhaz", "Abui", "Achang", "Acehnese", "Acheron", "Achi",
    "Acholi", "Achuar-Shiwiar", "Achumawi", "Adaizan", "Adamaua Fulfulde", "Adyghe", "Adzera", "Afar",
    "Afrikaans", "Aghul", "Aguacateco", "Aguaruna", "Ahom", "Ainu", "Ajië", "Akan",
    "Akhvakh", "Akkadian", "Aklan", "Akurio", "Alabama", "Albanian", "Aleut", "Algonquin",
    "Alsatian", "Altay", "Alur", "Amahuaca", "Amarakaeri", "Amarasi", "Amele", "Amharic",
    "Amis", "Andi", "Andoa", "Angami", "Anuki", "Anutan", "Apache", "Apma",
    "Arabela", "Arabic (Algerian)", "Arabic (Cypriot)", "Arabic (Egyptian)", "Arabic (Lebanese)", "Arabic (Modern Standard)", "Arabic (Moroccan)", "Arabic (Syrian)",
    "Arabic (Tunisian)", "Aragonese", "Arakanese", "Araki", "Aramaic (Ancient)", "Aramaic (Syriac)", "Aramaic (Neo-)", "Aranese",
    "Arapaho", "Arawak", "Arbëresh", "Archi", "Argobba", "Are", "Argobba", "Arikara",
    "Aringa", "Armenian", "Aromanian (Vlach)", "Arrernte", "Arvanitic", "Asháninka", "Ashéninka", "Assamese",
    "Assiniboine", "Assyrian(Neo-)", "Asturian", "Atayal", "Atikamekw", "Auhelawa", "Avar", "Avestan",
    "Avokaya", "Awadhi", "Awara", "Awing", "Awngi", "Aymara", "Äynu", "Azerbaijani",
    "Babine-Witsuwit'en", "Badaga", "Bagatha", "Bagvalal", "Bai", "Baka", "Balinese", "Balkar (Karachay-Balkar)",
    "Balti", "Baluchi", "Bambara", "Bamum", "Baniwa", "Bantawa", "Barai", "Bari",
    "Bartangi", "Bashkir", "Basque", "Bassa", "Batak Dairi", "Batak Karo", "Batak Mandailing", "Batak Simalungun",
    "Batak Toba", "Batsbi", "Bavarian", "Bavarian (Central)", "Bavarian (Northern)", "Bavarian (Southern)", "Beaver", "Beja",
    "Belarusian", "Beli", "Bemba", "Bench", "Bengali", "Bezhta", "Bhojpuri", "Biete",
    "Bikol", "Biloxi", "Bima", "Bislama", "Bisu", "Blackfoot", "Blagar", "Blin",
    "Bodo", "Bokar", "Bolinao", "Bongo", "Bora", "Bosnian", "Botlikh", "Bouyei",
    "Breton", "Budukh", "Buginese", "Buhid", "Buhutu", "Bulgarian", "Bundjalung", "Burmese",
    "Burushaski", "Buryat", "Busa", "Bushi", "Bhutanese", "Carrier", "Catalan", "Cayuga",
    "Cebuano", "Central Dusun", "Chagatai", "Chaha", "Chamorro", "Chechen", "Cherokee", "Cheyenne",
    "Chichewa", "Chickasaw", "Chinese", "Chinese (Cantonese)", "Chinese (Dungan)", "Chinese (Gan)", "Chinese (Hakka)", "Chinese (Mandarin)",
    "Chinese (Shanghainese)", "Chinese (Taiwanese)", "Chinese (Teochew)", "Chinese (Xiang)", "Chipewyan", "Choctaw", "Coastal Kadazan", "Comanche",
    "Cornish", "Corsican", "Cree", "Creek", "Croatian", "Czech", "Dakota", "Dangme",
    "Danish", "Dargwa", "Dari", "Dinka", "Ditidaht", "Dungan", "Dutch", "Dzongkha (Bhutanese)",
    "English (Old) / Anglo-Saxon", "Erzya", "Estonian", "Esperanto", "Ewe", "Eyak", "Faroese", "Fijian",
    "Finnish", "Flemish", "Fon", "French", "Frisian (North)", "Frisian (West)", "Friulan", "Fula",
    "Ga", "Galician", "Ganda", "Ge'ez", "Genoese", "Georgian", "German", "Godoberi",
    "Gooniyandi", "Greek", "Greenlandic", "Guernsey Norman", "Guarani", "Gujarati", "Gwich'in", "Haida",
    "Haitian Creole", "Hän", "Harari", "Hausa", "Hawaiian", "Hebrew", "Herero", "Hindi",
    "Huambisa", "Hungarian", "Icelandic", "Igbo", "Ilocano", "Indonesian", "Ingush", "Inuktitut",
    "Iñupiaq", "Irish (Gaelic)", "Italian", "Japanese", "Javanese", "Jersey Norman", "Kabardian", "Kabyle",
    "Kadazandusun", "Kaingang", "Kannada", "Kanuri", "Kapampangan", "Karakalpak", "Karelian", "Kashmiri",
    "Kashubian", "Kawaiisu", "Kazakh", "Khakas", "Khmer", "Khoekhoe", "Kikuyu", "Kinyarwanda",
    "Kiribati", "Kirundi", "Komi", "Kongo", "Konkani", "Korean", "Kumyk", "Kurdish",
    "Kven", "Kwanyama", "Kyrgyz", "Ladin", "Ladino", "Lahnda", "Lakota", "Lao",
    "Latin", "Latvian", "Laz", "Lezgian", "Limburgish", "Lingala", "Lithuanian", "Livonian",
    "Lombard", "Low German/Low Saxon", "Luo", "Luxembourgish", "Maasai/Maa", "Macedonian", "Maldivian", "Maithili",
    "Makah", "Malagasy", "Malay", "Malayalam", "Maltese", "Mandinka", "Manipuri", "Mansi",
    "Manx", "Māori", "Marathi", "Mari/Cheremis", "Marshallese", "Menominee", "Mirandese", "Mohawk",
    "Moksha", "Moldovan", "Mongolian", "Montagnais", "Nahuatl", "Naskapi", "Nauruan", "Navajo",
    "Occitan", "Oshiwambo", "Nepali", "Newari", "Niuean", "Nogai", "Noongar", "Northern Sotho",
    "Norwegian", "Nyamwezi", "Nyoro", "Odia", "Ojibwe", "Old English", "Old Norse", "O'odham",
    "Oromo", "Ossetian", "Palauan", "Pali", "Papiamento", "Pashto", "Persian", "Piedmontese",
    "Polish", "Portuguese", "Punjabi", "Quechua", "Raga", "Rapanui", "Rarotongan", "Romanian",
    "Romansh", "Romani", "Rotuman", "Russian", "Ruthenian", "Saami (Inari)", "Sámi (Kildin)", "Sámi (Lule)",
    "Sámi (North)", "Sámi (Pite)", "Sámi (Skolt)", "Sámi (South)", "Sámi (Ter)", "Sámi (Ume)", "Santali", "Samoan",
    "Sango", "Sanskrit", "Sardinian", "Sark Norman", "Scots", "Scottish Gaelic", "Selkup", "Serbian",
    "Shavante", "Shawnee", "Shona", "Shor", "Sicilian", "Sidamo", "Silesian", "Sindhi",
    "Sinhala", "Silt'e", "Slovak", "Slovenian", "Somali", "Soninke", "Sorbian (Lower)", "Sorbian (Upper)",
    "Southern Sotho", "South Slavey", "Spanish", "Sundanese", "Svan", "Swabish", "Swahili", "Swati",
    "Swedish", "Swiss German", "Sylheti", "Syriac", "Tabassaran", "Tagalog", "Tahitian", "Tai Nüa",
    "Tajik", "Tamahaq", "Tamasheq", "Tamazight", "Tamil", "Tatar", "Telugu", "Tetum",
    "Thai", "Tibetan", "Tigre", "Tigrinya", "Tlingit", "Tok Pisin", "Tonga", "Tongan",
    "Torwali", "Tsez", "Tsonga", "Tswana", "Tumbuka", "Turkish", "Turkmen", "Tuscarora",
    "Tuvaluan", "Tuvan", "Twi", "Udmurt", "Ukrainian", "Urdu", "Uyghur", "Uzbek",
    "Venda", "Venetian", "Veps", "Vietnamese", "Võro", "Votic", "Walloon", "Waray-Waray",
    "Welsh", "Wiradjuri", "Wolof", "Xamtanga", "Xhosa", "Yagua", "Yi", "Yiddish",
    "Yindjibarndi", "Yolngu", "Yoruba", "Yupik", "Zhuang", "Zulu", "Zuñi"
]

class World {
    
    internal var continents: [Continent] = []
    internal var languages: [Language] = []
    internal var name: String
    
    func getCountriesOf(_ continent: String) -> [Country]{
        for _continent in continents {
            if(_continent.name == continent){
                return _continent.countries
            }
        }
        
        fatalError("No continent found with this name!")
    }
    
    func add(countries: [String], _ continent: String){
        
        let temp_continent = Continent(name: continent)
        
        for country_name in countries{
            let country = Country(name: country_name)
            
            country.flag_name = country_name.lowercased()
            country.flag_name = country.flag_name?.replacingOccurrences(of: " ", with: "-")
            
            temp_continent.countries.append(country)
        }
        
        continents.append(temp_continent)
    }
    
    func add(_ all_languages: [String]) {
        
        for language in all_languages {
            self.languages.append(Language(name: language))
        }
        
    }
    
    init(name: String) {
        
        self.name = name
        
        add(countries: countries_africa, "Africa")
        add(countries: countries_asia, "Asia")
        add(countries: countries_australia_and_oceania, "Australia and Oceania")
        add(countries: countries_europe, "Europe")
        add(countries: countries_north_america, "North America")
        add(countries: countries_south_america, "South America")
        
        add(all_languages)
    }
}

class Country {
    internal var name : String? = nil
    internal var spoken_languages : [String] = []
    internal var flag_name : String?
    
    init(name: String) {
        self.name = NSLocalizedString(name, comment: "The country")
    }
}

class Continent {
    internal var name: String
    internal var countries: [Country] = []
    
    init(name: String) {
        self.name = NSLocalizedString(name, comment: "The continent")
    }
}

class Language {
    internal var name: String?
    
    init(name: String) {
        self.name = NSLocalizedString(name, comment: "The language")
    }
}
