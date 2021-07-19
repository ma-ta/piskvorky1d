//
//  ViewController.swift
//  Piskvorky1D
//
//  Created by Ma-TA on 17.07.2021.
//

import Cocoa

class ViewController: NSViewController {
    
    // NAPOJENÍ OVLÁDACÍCH PRVKŮ GUI
    
    // MENU
    // Nová hra
    @IBAction func newDocument(_ sender: Any) { novaHra() }
    // Nápověda
    @IBAction func showHelp(_ sender: Any) {
        
        let textNapovedy =
            """
            Vítejte ve hře \(NAZEV_APLIKACE).
            
            Cílem hry je získat nepřerušenou\nřadu \(POZADOVANYCH_POLICEK) symbolů \(ZNAKY_HRACU[0]!).
            
            Tvým protihráčem je\npočítač se znakem \(ZNAKY_HRACU[1]!).
            
            Mnoho štěstí !
            """
        
        func dialogNapoveda(nadpis: String, text: String) -> Bool {
            let alert = NSAlert()
            alert.messageText = nadpis
            alert.informativeText = text
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            return alert.runModal() == .alertFirstButtonReturn
        }
        
        _ = dialogNapoveda(nadpis: "Nápověda", text: textNapovedy)
        
    }
    
    // FORMULÁŘ
    @IBOutlet weak var stitekStav: NSButton!
    @IBOutlet weak var stitekZnakHrace: NSButton!
    @IBOutlet weak var stitekVysledek: NSTextField!
    
    var herniPolicka: [NSButton] = []
  
    
    // NASTAVENÍ KONSTANT A VÝCHOZÍHO STAVU
    
    let NAZEV_APLIKACE = "Piškvorky 1D"
    // počet políček herního pole
    let POCET_POLICEK: UInt8 = 10
    let POZADOVANYCH_POLICEK: UInt8 = 3
    // symboly hráčů
    let ZNAKY_HRACU: [UInt8: String] = [0: "✕",
                                        1: "○"]
    // řetězcové konstanty
    let VYHRA = "V í t ě z e m   j e".uppercased()
    let REMIZA = "R e m í z a !".uppercased()
    let HRAC1 = "Jsi na tahu"
    let HRAC2 = "Hraje počítač"
    
    // určuje, zda hra ještě probíhá
    var hra: Bool = true
    // určuje hráče, který je na tahu
    var naTahu: Int8 = 0
    // programové herní pole (icinializováno níže)
    var herniPole: [Int8] = []
    // zbývající volná herní políčka
    var volnychPolicek: UInt8 = 0
    // počet tahů nutných k výhře
    var hrac1kVyhre: UInt8 = 0
    var hrac2kVyhre: UInt8 = 0
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // vložení GUI políček do pole
        for i in 0...POCET_POLICEK-1 {
            herniPolicka.append(view.viewWithTag(Int(i)) as! NSButton)
        }

        novaHra()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    // zobrazí aktuální programové herní pole v GUI
    func vykresliHerniPole() {
        // zakreslení symbolů hráčů do herních políček
        for i in 0...POCET_POLICEK-1 {
            
            var symbol: String
            
            switch herniPole[Int(i)] {
                case 0:
                    symbol = ZNAKY_HRACU[0]!
                case 1:
                    symbol = ZNAKY_HRACU[1]!
                default:
                    symbol = ""
            }
            
            herniPolicka[Int(i)].title = symbol
        }
    }
    
    // vrátí výchozí stav a restartuje hru
    func novaHra() {
        
        // textové informace o stavu hry
        let INFO_NA_TAHU: [UInt8: String] = [
            0: HRAC1,
            1: HRAC2
        ]
        
        // určuje, zda hra ještě probíhá
        hra = true
        // určuje hráče, který je na tahu
        naTahu = Int8(Int.random(in: 0...1))
        // zbývající volná herní políčka
        volnychPolicek = POCET_POLICEK
        // počet zbývajících tahů nutných k výhře
        hrac1kVyhre = POZADOVANYCH_POLICEK
        hrac2kVyhre = POZADOVANYCH_POLICEK
        
        // inicializace prázdného programového herního pole
        herniPole =
            [Int8](repeating: -1, count: Int(POCET_POLICEK))
        volnychPolicek = POCET_POLICEK
        vykresliHerniPole()
        
        stitekStav.title = "\(INFO_NA_TAHU[UInt8(naTahu)]!)"
        stitekZnakHrace.title = "\(ZNAKY_HRACU[UInt8(naTahu)]!)"
    }
    
    // vyhodnocení stavu hry
    func vyhodnot() -> Int8 {
        // stav:
        // -1 = remíza
        //  0 = hra pokračuje
        //  1 = výhra
        
        for i in 1...POCET_POLICEK-2 {
            if herniPole[Int(i)] != -1 {
                if herniPole[Int(i)] == herniPole[Int(i)-1]
                    && herniPole[Int(i)] == herniPole[Int(i)+1] {
                        return 1  // výhra
                }
            }
        }
        
        if volnychPolicek < 1 {
            return -1  // došla volná políčka = remíza
        }
        
        return 0  // hra pokračuje
    }
    
    
    // zpracování aktuálního tahu
    func tah(_ sender: NSButton) {
        
        // aktualizace programového herního pole
        herniPole[sender.tag] = naTahu
        volnychPolicek -= 1
        vykresliHerniPole()
        
        // debug log
        print(herniPole)
        print("Volných políček: \(volnychPolicek)")
        //print("hráč \(ZNAKY_HRACU[0]!) k výhře: \(hrac1kVyhre)")
        //print("hráč \(ZNAKY_HRACU[1]!) k výhře: \(hrac2kVyhre)")
        
        let vyhodnoceni = vyhodnot()
        switch vyhodnoceni {
        case -1,
              1:
            konecHry(stav: vyhodnoceni)
        default:
            // přepnutí aktivního hráče
            switch naTahu {
            case 0:
                naTahu = 1
                stitekStav.title = "\(HRAC2)"
            default:
                naTahu = 0
                stitekStav.title = "\(HRAC1)"
                
            }
            stitekZnakHrace.title = "\(ZNAKY_HRACU[UInt8(naTahu)]!)"
        }

    }
    
    // ukončí hru a zobrazí výherce
    func konecHry(stav: Int8) {
        if stav == 1 {
            print("Vyhrává hráč \(ZNAKY_HRACU[UInt8(naTahu)]!) !")  // debug log
            
            stitekStav.title = VYHRA
        } else if (stav == -1) {
            print("Došlo k remíze!")  // debug log
            
            stitekStav.title = REMIZA
            stitekZnakHrace.title = ""
        }
        
        hra = false
    }
    
    
    // GUI
    
    // odchytí kliknutí na herní políčko
    @IBAction func polickoClick(_ sender: NSButton) {
        
        print("\(type(of: sender)): \(sender.tag)")  // debug log
        
        if hra {
            // při splnění podmínek
            if sender.title == "" {
                // vyhodnocení tahu
                tah(sender)
            
            // políčko je již obsazeno
            } else {
                print("Políčko již náleží hráči \(sender.title)")  // debug log
            }
        // hra neprobíhá
        } else {
            print("Hra neprobíhá")  // debug log
        }
    }
    


}

