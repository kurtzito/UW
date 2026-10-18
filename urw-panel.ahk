#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; =====================================================================
;  Panel lateral con mouse para UnReal World
;
;  - Un solo panel en una de las franjas negras a los costados del juego
;    (el juego se dibuja en 4:3). Se pasa de lado con el botón "Lado".
;  - Los botones NO le quitan el foco al juego y mandan la tecla real.
;  - Menos usado arriba, más usado abajo. Esc, Espacio y Enter al fondo.
;  - Clic central del mouse = Esc (solo con la ventana del juego activa).
;  - Candadito: cada clic pasa por 🔒 cerrado → 🔓 mover (intercambiar
;    botones de lugar) → 🎨 colores (elegir un color de la paleta y tocar
;    los botones para pintarlos) → 🔒 cerrado.
;  - Idiomas: español, inglés, finés, portugués (Brasil) e italiano.
;  - Ocultar deja una lengüeta en el borde de la pantalla; un clic la
;    devuelve. También: Ctrl+Alt+P, Ctrl+Alt+L (lado), doble clic en el
;    ícono de la bandeja.
;
;  Uso: instalar AutoHotkey v2, abrir el juego, doble clic en este archivo.
;  Lo que elegís (lado, idioma, orden y colores de botones) se guarda en
;  urw-panel.ini, junto a este archivo.
; =====================================================================

; ---------- CONFIGURACIÓN (se puede tocar) ----------
PANEL_W      := 0        ; ancho del panel en píxeles; 0 = calcularlo solo
GAME_RATIO   := 4/3      ; proporción de la imagen del juego
OPACITY      := 245      ; 255 = opaco
USE_EMOJI    := true     ; false = sin dibujitos (candado, globo) si no se ven bien
SEND_MODE    := "Event"  ; si el juego ignora las teclas, probar "Input" o "Play"
KEY_DELAY    := 15       ; ms entre teclas
KEY_PRESS    := 35       ; ms que dura cada tecla apretada
REPEAT_FIRST := 400      ; ms antes de empezar a repetir al mantener apretado
REPEAT_EVERY := 120      ; ms entre repeticiones
TARGET_WIN   := ""       ; opcional, por ejemplo "ahk_exe urw.exe"
MBUTTON_ESC  := true     ; true = el clic central del mouse manda Esc
GAME_WIN     := "ahk_exe urw.exe"   ; el clic central solo actúa si la ventana activa es este programa
                         ; (también vale un texto del título, ej. "UnReal World"). Vacío = en todas las ventanas.
INI_FILE     := A_ScriptDir "\urw-panel.ini"

SetKeyDelay(KEY_DELAY, KEY_PRESS)
SetTitleMatchMode(2)

; ---------- Idiomas ----------
LANGCODES := ["es", "en", "fi", "pt", "it"]
LANGNAMES := ["Español", "English", "Suomi", "Português", "Italiano"]

IndexOf(arr, val) {
    for i, v in arr {
        if (v = val)
            return i
    }
    return 0
}

LANGI := IndexOf(LANGCODES, IniRead(INI_FILE, "panel", "lang", "es"))
if (LANGI = 0)
    LANGI := 1
SIDE := IniRead(INI_FILE, "panel", "side", "R")
if (SIDE != "L" && SIDE != "R")
    SIDE := "R"

; Textos de la interfaz: [es, en, fi, pt, it]
UIS := Map()
Ui(key, es, en, fi, pt, it) {
    UIS[key] := [es, en, fi, pt, it]
}
U(key) {
    return UIS[key][LANGI]
}
Ui("ready",   "Listo", "Ready", "Valmis", "Pronto", "Pronto")
Ui("locked",  "Bloq.", "Lock", "Lukittu", "Bloq.", "Bloc.")
Ui("editing", "Editar", "Edit", "Muokkaa", "Editar", "Modif.")
Ui("pick1",   "Editar: elegí un botón", "Edit: pick a button", "Muokkaus: valitse painike", "Editar: escolha um botão", "Modifica: scegli un tasto")
Ui("pick2",   "Ahora elegí con cuál cambiarlo", "Now pick the one to swap with", "Valitse vaihdettava painike", "Agora escolha com qual trocar", "Ora scegli con quale scambiare")
Ui("nofit",   "No cabe ahí", "Doesn't fit there", "Ei mahdu sinne", "Não cabe aí", "Non ci sta lì")
Ui("moved",   "Listo, cambiado", "Done, swapped", "Valmis, vaihdettu", "Pronto, trocado", "Fatto, scambiato")
Ui("keysoff", "Modo edición: sin teclas", "Edit mode: keys are off", "Muokkaustila: ei näppäimiä", "Modo edição: sem teclas", "Modalità modifica: niente tasti")
Ui("needlock","Abrí el candado primero", "Unlock first", "Avaa lukitus ensin", "Abra o cadeado primeiro", "Sblocca prima")
Ui("resetq",  "¿Restaurar el orden original?", "Restore the original order?", "Palautetaanko alkuperäinen järjestys?", "Restaurar a ordem original?", "Ripristinare l'ordine originale?")
Ui("paint",   "Colores", "Colors", "Värit", "Cores", "Colori")
Ui("paint1",  "Colores: elegí un color", "Colors: pick a color", "Värit: valitse väri", "Cores: escolha uma cor", "Colori: scegli un colore")
Ui("paint2",  "Tocá los botones a pintar", "Click buttons to paint", "Napsauta maalattavia", "Toque os botões a pintar", "Tocca i tasti da colorare")
Ui("painted", "Listo, pintado", "Done, painted", "Valmis, maalattu", "Pronto, pintado", "Fatto, colorato")
Ui("nobrush", "Primero elegí un color", "Pick a color first", "Valitse ensin väri", "Escolha uma cor primeiro", "Scegli prima un colore")
Ui("resetc",  "¿Restaurar los colores originales?", "Restore the original colors?", "Palautetaanko alkuperäiset värit?", "Restaurar as cores originais?", "Ripristinare i colori originali?")
Ui("confirm", "Confirmar", "Confirm", "Vahvista", "Confirmar", "Conferma")
Ui("mclick",  "clic central", "middle click", "keskipainike", "clique central", "clic centrale")
Ui("tray",    "Mostrar / ocultar panel (Ctrl+Alt+P)", "Show / hide panel (Ctrl+Alt+P)", "Näytä / piilota paneeli (Ctrl+Alt+P)", "Mostrar / ocultar painel (Ctrl+Alt+P)", "Mostra / nascondi pannello (Ctrl+Alt+P)")
Ui("traysd",  "Cambiar de lado (Ctrl+Alt+L)", "Switch side (Ctrl+Alt+L)", "Vaihda puolta (Ctrl+Alt+L)", "Trocar de lado (Ctrl+Alt+L)", "Cambia lato (Ctrl+Alt+L)")

; ---------- Colores por grupo: [fondo, texto] ----------
COL := Map()
COL["mov"]  := ["0B5FE0", "FFFFFF"]   ; movimiento y direcciones
COL["act"]  := ["7A4A1E", "FFFFFF"]   ; actividad general
COL["sup"]  := ["6E6868", "FFFFFF"]   ; supervivencia diaria
COL["menu"] := ["7DBE1E", "111111"]   ; menús
COL["cmb"]  := ["C0392B", "FFFFFF"]   ; combate y caza
COL["key"]  := ["E0701C", "111111"]   ; teclas genéricas
COL["abs"]  := ["F2C230", "111111"]   ; espera, zoom, mirar
COL["info"] := ["35D6E0", "111111"]   ; información
COL["sys"]  := ["3B4A6B", "FFFFFF"]   ; panel y sistema
COL["esc"]  := ["FFFFFF", "111111"]   ; Esc: botón blanco
COL["spc"]  := ["D81B8C", "FFFFFF"]   ; Espacio y Enter: magenta
COL["sel"]  := ["39FF14", "111111"]   ; botón elegido en modo edición
COL["emp"]  := ["2A323D", "8A94A3"]   ; celda vacía en modo edición

; Paleta del modo colores (se puede tocar). El texto sale negro o blanco según el fondo.
; Antes de estos va siempre el ↺, que devuelve al botón su color original.
PALETTE := ["0B5FE0", "35D6E0", "1E7A3C", "7DBE1E", "F2C230", "E0701C", "C0392B"
          , "D81B8C", "6A3FB5", "7A4A1E", "6E6868", "111111", "FFFFFF"]
PAL_ROWS := 2      ; filas de la paleta
PAL_H    := 0.8    ; alto de cada fila, en proporción a un botón

; Texto negro o blanco según qué tan claro es el fondo
Contrast(hex) {
    r := Integer("0x" . SubStr(hex, 1, 2))
    g := Integer("0x" . SubStr(hex, 3, 2))
    b := Integer("0x" . SubStr(hex, 5, 2))
    return ((r * 299 + g * 587 + b * 114) / 1000 > 128) ? "111111" : "FFFFFF"
}

; Color de un botón: el elegido en el modo colores, o el de su grupo
ColorOf(d) {
    if (d.id != "" && CUST.Has(d.id))
        return [CUST[d.id], Contrast(CUST[d.id])]
    return COL[d.grp]
}

LoadColors() {
    m := Map()
    for part in StrSplit(IniRead(INI_FILE, "colors", "data", ""), ";") {
        f := StrSplit(part, ":")
        if (f.Length = 2 && DEF.Has(f[1]) && RegExMatch(f[2], "^[0-9A-Fa-f]{6}$"))
            m[f[1]] := StrUpper(f[2])
    }
    return m
}

SaveColors() {
    txt := ""
    for id, hex in CUST
        txt .= id . ":" . hex . ";"
    if (txt = "") {
        try IniDelete(INI_FILE, "colors", "data")
    } else {
        try IniWrite(txt, INI_FILE, "colors", "data")
    }
}

; ---------- Definición de botones ----------
; B(id, grupo, tecla a enviar, tecla a mostrar, "es|en|fi|pt|it", "nombres completos" (opcional), opciones)
; Teclas: + = Shift, ^ = Ctrl, ! = Alt. Una letra con + sale en mayúscula.
DEF := Map()
B(id, grp, snd, shown, labels, tips := "", o := "") {
    d := {id: id, grp: grp, snd: snd, shown: shown, act: "", rep: false, conf: false
        , span: 1, h: 1.0, big: 0, emo: false
        , labels: StrSplit(labels, "|"), tips: (tips = "" ? "" : StrSplit(tips, "|"))}
    if IsObject(o) {
        for k in ["act", "rep", "conf", "span", "h", "big", "emo"] {
            if HasProp(o, k)
                d.%k% := o.%k%
        }
    }
    DEF[id] := d
    return d
}

; ----- Panel (arriba, fijos) -----
B("H_LOCK",  "sys",  "", "", "x|x|x|x|x", "", {act: "lock", emo: true})
B("H_SIDE",  "sys",  "", "", "⇄ Lado|⇄ Side|⇄ Puoli|⇄ Lado|⇄ Lato", "", {act: "side"})
B("H_LANG",  "sys",  "", "", "x|x|x|x|x", "", {act: "lang", emo: true})
B("H_HIDE",  "sys",  "", "", "Ocultar|Hide|Piilota|Ocultar|Nascondi", "", {act: "hide"})
B("H_CLOSE", "sys",  "", "", "Cerrar|Close|Sulje|Fechar|Chiudi", "", {act: "exit"})
B("H_HELP",  "info", "?", "?", "Ayuda|Help|Ohje|Ajuda|Aiuto")
B("H_SAVE",  "sys",  "^s", "Ctrl+S", "Guardar|Save|Tallenna|Salvar|Salva"
   , "Guardar y salir|Save and quit|Tallenna ja poistu|Salvar e sair|Salva ed esci", {conf: true})
B("H_QUIT",  "sys",  "+q", "Shift+Q", "Salir juego|Quit game|Lopeta peli|Sair do jogo|Esci gioco"
   , "Salir del juego|Quit the game|Lopeta peli|Sair do jogo|Esci dal gioco", {conf: true})
B("H_RESET", "sys",  "", "", "Restaurar|Reset|Palauta|Restaurar|Ripristina", "", {act: "reset"})

; ----- Menús e información -----
B("INV",  "menu", "i", "i", "Inventario|Inventory|Tavarat|Inventário|Inventario")
B("SKL",  "menu", "s", "s", "Habilidades|Skills|Taidot|Habilidades|Abilità")
B("CRF",  "menu", "+m", "Shift+M", "Fabricar|Craft|Valmista|Fabricar|Crea")
B("PLUS", "menu", "{+}", "+", "+ Mejorar|+ Improve|+ Paranna|+ Melhorar|+ Migliora", "", {rep: true})
B("MINS", "menu", "-", "-", "− Bajar|− Degrade|− Heikennä|− Reduzir|− Riduci", "", {rep: true})
B("RIT",  "menu", "{F4}", "F4", "Rituales|Rituals|Rituaalit|Rituais|Rituali")
B("ARM",  "info", "+a", "Shift+A", "Armadura|Armour|Panssari|Armadura|Armatura")
B("PRF",  "info", "+p", "Shift+P", "Perfil|Profile|Profiili|Perfil|Profilo")
B("LOG",  "info", "+l", "Shift+L", "Registro|Log|Loki|Registro|Registro")
B("QST",  "info", "{F2}", "F2", "Misiones|Quests|Tehtävät|Missões|Missioni")
B("MSG",  "info", "v", "v", "Mensajes|Messages|Viestit|Mensagens|Messaggi")
B("MAP",  "info", "{F6}", "F6", "Mapa|Map|Kartta|Mapa|Mappa")
B("ENC",  "info", "{F1}", "F1", "Enciclopedia|Encyclopedia|Tietosanak.|Enciclopédia|Enciclopedia"
   , "Enciclopedia|Encyclopedia|Tietosanakirja|Enciclopédia|Enciclopedia")
B("CRS",  "info", "{F5}", "F5", "Curso juego|Game course|Pelin kulku|Curso jogo|Corso gioco"
   , "Curso del juego|Game course|Pelin kulku|Curso do jogo|Corso del gioco")

; ----- Supervivencia -----
B("EAT",  "sup", "e", "e", "Comer|Eat|Syö|Comer|Mangia")
B("DRK",  "sup", "q", "q", "Beber|Drink|Juo|Beber|Bevi")
B("FIR",  "sup", "f", "f", "Fuego|Fire|Tuli|Fogo|Fuoco")
B("WEAR", "sup", "+w", "Shift+W", "Vestir|Wear|Pue|Vestir|Indossa")
B("TOFF", "sup", "+t", "Shift+T", "Quitar|Remove|Riisu|Tirar|Togli")
B("SLP",  "sup", "+z", "Shift+Z", "Dormir|Sleep|Nuku|Dormir|Dormi")
B("BUT",  "sup", "b", "b", "Destazar|Butcher|Teurasta|Esquartejar|Macella")
B("RST",  "abs", "!-", "Alt+-", "Descansar|Rest|Lepää|Descansar|Riposa")
B("WAIT", "abs", "-", "-", "Esperar…|Wait…|Odota…|Esperar…|Aspetta…", "Esperar (menú)|Wait (menu)|Odota (valikko)|Esperar (menu)|Aspetta (menu)")

; ----- Mirar, hablar, zoom -----
B("LOOK", "abs", "l", "l", "Mirar obj.|Look target|Katso kohde|Olhar alvo|Osserva"
   , "Mirar objetivo|Look at target|Katso kohdetta|Olhar o alvo|Osserva il bersaglio")
B("EXA",  "abs", "x", "x", "Exam. ady.|Exam. adj.|Tutki vier.|Exam. adj.|Esam. adiac."
   , "Examinar adyacente|Examine adjacent|Tutki viereistä|Examinar adjacente|Esamina adiacente")
B("EXH",  "abs", ":", ":", "Exam. aquí|Examine here|Tutki tässä|Exam. aqui|Esamina qui"
   , "Examinar aquí|Examine here|Tutki tässä|Examinar aqui|Esamina qui")
B("TALK", "abs", "+c", "Shift+C", "Hablar|Talk|Puhu|Falar|Parla")
B("ORD",  "abs", "{!}", "!", "Órdenes|Orders|Käske|Ordens|Ordini"
   , "Dar órdenes|Give orders|Anna käsky|Dar ordens|Dai ordini")
B("MMT",  "key", "7", "7", "Mant. mapa|Map maint.|Kart. ylläp.|Manut. mapa|Manut. mappa"
   , "Mantener mapa (7)|Map maintenance (7)|Kartan ylläpito (7)|Manutenção do mapa (7)|Manutenzione mappa (7)")
B("ZP",   "abs", "^{NumpadAdd}", "Ctrl++", "Zoom +|Zoom +|Zoomaa +|Zoom +|Zoom +", "", {rep: true})
B("ZM",   "abs", "^{NumpadSub}", "Ctrl+-", "Zoom −|Zoom −|Zoomaa −|Zoom −|Zoom −", "", {rep: true})

; ----- Combate -----
B("KICK", "cmb", "0", "0", "Patada|Kick|Potku|Chute|Calcio")
B("PUNC", "cmb", "9", "9", "Puñetazo|Punch|Nyrkkisku|Soco|Pugno")
B("RATK", "cmb", "3", "3", "Rep. ataque|Repeat atk.|Toista isku|Rep. ataque|Ripeti att."
   , "Repetir ataque|Repeat attack|Toista isku|Repetir ataque|Ripeti attacco")
B("W1",   "cmb", "1", "1", "Arma 1|Weapon 1|Ase 1|Arma 1|Arma 1")
B("W2",   "cmb", "2", "2", "Arma 2|Weapon 2|Ase 2|Arma 2|Arma 2")
B("THR",  "cmb", "t", "t", "Lanzar|Throw|Heitä|Lançar|Lancia")
B("WLD",  "cmb", "w", "w", "Empuñar|Wield|Ota käteen|Empunhar|Impugna")
B("HEAL", "cmb", "{F7}", "F7", "Curar|Treat|Hoida|Curar|Cura"
   , "Curar heridas|Treat wounds|Hoida haavat|Curar feridas|Cura le ferite")
B("SWAP", "act", "+x", "Shift+X", "Alt. manos|Swap hands|Vaihda kättä|Trocar mãos|Cambia mano"
   , "Cambiar de mano|Swap hands|Vaihda kättä|Trocar de mão|Cambia mano")

; ----- Actividad -----
B("TKW",  "act", "^,", "Ctrl+,", "Tomar+emp.|Take+wield|Ota+käteen|Pegar+emp.|Prendi+imp."
   , "Tomar y empuñar|Take and wield|Ota ja tartu aseeseen|Pegar e empunhar|Prendi e impugna")
B("HIDA", "act", "h", "h", "Esconderse|Hide|Piiloudu|Esconder|Nasconditi")
B("STND", "act", "u", "u", "Levantarse|Stand up|Nouse|Levantar|Alzati")
B("PICK", "act", "g", "g", "Recoger|Pick up|Poimi|Pegar|Raccogli")
B("DROP", "act", "d", "d", "Soltar|Drop|Pudota|Soltar|Lascia")
B("PCKA", "act", "+g", "Shift+G", "Recoger ady.|Pick adj.|Poimi vier.|Pegar adj.|Racc. adiac."
   , "Recoger adyacente|Pick up adjacent|Poimi viereinen|Pegar adjacente|Raccogli adiacente")
B("MOVO", "act", "m", "m", "Mover obj.|Move obj.|Siirrä esine|Mover obj.|Sposta ogg."
   , "Mover objeto|Move object|Siirrä esinettä|Mover objeto|Sposta oggetto")
B("PUSH", "act", "p", "p", "Empujar|Push|Työnnä|Empurrar|Spingi")
B("APLY", "act", "a", "a", "Aplicar|Apply|Käytä|Aplicar|Applica")
B("OPEN", "act", "o", "o", "Abrir pta.|Open door|Avaa ovi|Abrir porta|Apri porta"
   , "Abrir puerta|Open door|Avaa ovi|Abrir porta|Apri porta")
B("CLOS", "act", "c", "c", "Cerrar pta.|Close door|Sulje ovi|Fechar porta|Chiudi porta"
   , "Cerrar puerta|Close door|Sulje ovi|Fechar porta|Chiudi porta")
B("REPT", "act", "r", "r", "Repetir|Repeat|Toista|Repetir|Ripeti")
B("MOVE", "act", "/", "/", "Movimiento|Movement|Liike|Movimento|Movimento")

; ----- Teclas sueltas -----
B("N4",   "key", "4", "4", "4|4|4|4|4")
B("N5",   "key", "5", "5", "5|5|5|5|5")
B("N6",   "key", "6", "6", "6|6|6|6|6")
B("N8",   "key", "8", "8", "8|8|8|8|8")
B("TAB",  "key", "{Tab}", "Tab", "Tab|Tab|Tab|Tab|Tab")
B("PGU",  "key", "{PgUp}", "RePág", "RePág|PgUp|Sivu ↑|Pág ↑|Pag ↑")
B("PGD",  "key", "{PgDn}", "AvPág", "AvPág|PgDn|Sivu ↓|Pág ↓|Pag ↓")

; ----- Movimiento -----
B("TL",   "mov", "{Home}", "Inicio", "Giro 90° ←|Turn 90° ←|Käänny 90°←|Girar 90° ←|Gira 90° ←")
B("UP",   "mov", "{Up}", "↑", "↑|↑|↑|↑|↑", "", {rep: true})
B("TR",   "mov", "{PgUp}", "RePág", "Giro 90° →|Turn 90° →|Käänny 90°→|Girar 90° →|Gira 90° →")
B("LEFT", "mov", "{Left}", "←", "←|←|←|←|←", "", {rep: true})
B("WT1",  "abs", ".", ".", "Esperar 1|Wait 1|Odota 1|Esperar 1|Aspetta 1"
   , "Esperar un turno|Wait one turn|Odota yksi vuoro|Esperar um turno|Aspetta un turno", {rep: true})
B("RGHT", "mov", "{Right}", "→", "→|→|→|→|→", "", {rep: true})
B("SL",   "mov", "^{Left}", "Ctrl+←", "Paso ←|Step ←|Askel ←|Passo ←|Passo ←"
   , "Paso lateral izquierdo|Sidestep left|Sivuaskel vasemmalle|Passo lateral esquerdo|Passo laterale sinistro", {rep: true})
B("DOWN", "mov", "{Down}", "↓", "↓|↓|↓|↓|↓", "", {rep: true})
B("SR",   "mov", "^{Right}", "Ctrl+→", "Paso →|Step →|Askel →|Passo →|Passo →"
   , "Paso lateral derecho|Sidestep right|Sivuaskel oikealle|Passo lateral direito|Passo laterale destro", {rep: true})
B("T180", "mov", "{End}", "Fin", "Giro 180°|Turn 180°|Käänny 180°|Girar 180°|Gira 180°")
B("SB",   "mov", "^{Down}", "Ctrl+↓", "Paso atrás|Step back|Taka-askel|Passo atrás|Passo dietro", "", {rep: true})
B("RUN",  "act", "+r", "Shift+R", "Correr|Run|Juokse|Correr|Corri")

; ----- Abajo de todo -----
B("SPC",  "spc", "{Space}", "Espacio", "Espacio|Space|Välilyönti|Espaço|Spazio", "", {span: 2, h: 1.5, big: 3})
B("ENT",  "spc", "{Enter}", "Enter", "Enter|Enter|Enter|Enter|Invio", "", {h: 1.5, big: 3})
B("ESC",  "esc", "{Esc}", "Esc", "ESC|ESC|ESC|ESC|ESC", "Esc|Esc|Esc|Esc|Esc", {span: 3, h: 1.3, big: 3})

COLS := 3

; Orden original de los botones movibles: una fila por línea, "." = celda vacía.
; Un botón ancho ocupa varias celdas (SPC = 2, ESC = 3).
DefaultRows := [
    "INV SKL CRF",
    "PLUS MINS RIT",
    "ARM PRF LOG",
    "QST MSG MAP",
    "ENC CRS .",
    "EAT DRK FIR",
    "WEAR TOFF SLP",
    "BUT RST WAIT",
    "LOOK EXA EXH",
    "TALK ORD MMT",
    "ZP ZM .",
    "KICK PUNC RATK",
    "W1 W2 THR",
    "WLD HEAL SWAP",
    "TKW HIDA STND",
    "PICK DROP PCKA",
    "MOVO PUSH APLY",
    "OPEN CLOS REPT",
    "MOVE N4 N5",
    "N6 N8 TAB",
    "PGU PGD .",
    "TL UP TR",
    "LEFT WT1 RGHT",
    "SL DOWN SR",
    "T180 SB RUN",
    "SPC ENT",
    "ESC"
]
HeaderRows := [["H_LOCK", "H_SIDE", "H_LANG"], ["H_HIDE", "H_CLOSE", "H_HELP"], ["H_SAVE", "H_QUIT", "H_RESET"]]

; ---------- Posiciones de los botones movibles ----------
DefaultPos() {
    p := Map()
    for r, line in DefaultRows {
        c := 1
        for tok in StrSplit(line, " ") {
            if (tok = ".") {
                c += 1
                continue
            }
            p[tok] := {r: r, c: c}
            c += DEF[tok].span
        }
    }
    return p
}

PosValid(cand) {
    base := DefaultPos()
    if (cand.Count != base.Count)
        return false
    used := Map()
    for id, p in cand {
        if !base.Has(id)
            return false
        w := DEF[id].span
        if (p.r < 1 || p.r > DefaultRows.Length || p.c < 1 || p.c + w - 1 > COLS)
            return false
        Loop w {
            key := p.r . "," . (p.c + A_Index - 1)
            if used.Has(key)
                return false
            used[key] := true
        }
    }
    return true
}

LoadPos() {
    txt := IniRead(INI_FILE, "layout", "data", "")
    if (txt = "")
        return DefaultPos()
    cand := Map()
    for part in StrSplit(txt, ";") {
        if (part = "")
            continue
        f := StrSplit(part, ":")
        if (f.Length != 3 || !IsInteger(f[2]) || !IsInteger(f[3]) || !DEF.Has(f[1]))
            return DefaultPos()
        cand[f[1]] := {r: Integer(f[2]), c: Integer(f[3])}
    }
    return PosValid(cand) ? cand : DefaultPos()
}

SavePos() {
    txt := ""
    for id, p in POS
        txt .= id . ":" . p.r . ":" . p.c . ";"
    try IniWrite(txt, INI_FILE, "layout", "data")
}

; Qué botón ocupa la celda (fila, columna); "" si está vacía
Owner(r, c) {
    for id, p in POS {
        if (p.r = r && c >= p.c && c <= p.c + DEF[id].span - 1)
            return id
    }
    return ""
}

; ---------- Textos de los botones ----------
Lbl(d) {
    if (d.id = "H_LOCK" && PAINTING)
        return (USE_EMOJI ? "🎨 " : "") . U("paint")
    if (d.id = "H_LOCK")
        return (USE_EMOJI ? (EDITING ? "🔓 " : "🔒 ") : "") . (EDITING ? U("editing") : U("locked"))
    if (d.id = "H_LANG")
        return (USE_EMOJI ? "🌐 " : "") . LANGNAMES[LANGI]
    if (d.id = "ESC")
        return "ESC" . (MBUTTON_ESC ? "   ·   " . U("mclick") : "")
    return d.labels[LANGI]
}

Tip(d) {
    return IsObject(d.tips) ? d.tips[LANGI] : Lbl(d)
}

; ---------- Medidas ----------
PAD  := 4
GAP  := 3
scrW := A_ScreenWidth
scrH := A_ScreenHeight
PW := PANEL_W > 0 ? PANEL_W : Floor((scrW - scrH * GAME_RATIO) / 2)
PW := Max(PW, 150)
BW := Floor((PW - 2 * PAD - (COLS - 1) * GAP) / COLS)

; Tamaño de letra: se mide cada texto para que ninguno quede cortado
FITS := Map()
FITLANG := 0
FS := 8
BH := 30

ComputeFits() {
    global FITS, FITLANG
    FITS := Map()
    pending := Map()
    for id, d in DEF {
        if (d.span > 1 || id = "ESC")
            continue
        lb := Lbl(d)
        if (StrLen(lb) > 1)
            pending[lb] := true
    }
    pending[(USE_EMOJI ? "🔓 " : "") . U("editing")] := true
    pending[(USE_EMOJI ? "🔒 " : "") . U("locked")] := true
    pending[(USE_EMOJI ? "🎨 " : "") . U("paint")] := true
    maxW := BW - 10
    Loop 7 {
        sz := 13 - A_Index
        tmp := Gui("-DPIScale")
        tmp.SetFont("s" sz " bold", "Segoe UI")
        done := []
        for lb, flag in pending {
            t := tmp.Add("Text", , lb)
            t.GetPos(, , &w)
            if (w <= maxW) {
                FITS[lb] := sz
                done.Push(lb)
            }
        }
        tmp.Destroy()
        for lb in done
            pending.Delete(lb)
    }
    for lb, flag in pending
        FITS[lb] := 6
    FITLANG := LANGI
}

PickFS() {
    ; tamaño general: el que le queda bien a casi todos los textos (los más largos se achican solos)
    counts := Map()
    n := 0
    for lb, sz in FITS {
        counts[sz] := counts.Has(sz) ? counts[sz] + 1 : 1
        n += 1
    }
    target := Ceil(n * 0.12)
    acc := 0
    pick := 12
    Loop 7 {
        sz := 5 + A_Index
        if counts.Has(sz) {
            acc += counts[sz]
            if (acc >= target) {
                pick := sz
                break
            }
        }
    }
    byH := Floor((BH - 8) * 72 / A_ScreenDPI)
    return Max(6, Min(pick, byH, 11))
}

; ---------- Construcción de la ventana ----------
G := ""
TG := ""
BTN := Map()
TABBTN := Map()
POS := LoadPos()
EDITING := false
PAINTING := false
BRUSH := -1        ; color elegido en el modo colores: -1 = ninguno, 0 = original, n = PALETTE[n]
CUST := LoadColors()
SELP := ""
MSG := ""
MSGGRP := ""
PANELVIS := true
StatusTxt := ""

BuildGui() {
    global G, BTN, StatusTxt, FS, BH
    BTN := Map()

    ; alto de cada fila de la zona movible
    nRows := DefaultRows.Length
    rowF := []
    Loop nRows
        rowF.Push(1.0)
    for id, p in POS {
        if (DEF[id].h > rowF[p.r])
            rowF[p.r] := DEF[id].h
    }
    units := 4.0
    for f in rowF
        units += f
    totalRows := 4 + nRows
    if PAINTING {
        units += PAL_ROWS * PAL_H
        totalRows += PAL_ROWS
    }
    BH :=Floor((scrH - 2 * PAD - GAP * (totalRows - 1) - 20) / units)
    BH := Max(16, Min(56, BH))

    if (FITLANG != LANGI)
        ComputeFits()
    FS := PickFS()

    gu := Gui("+AlwaysOnTop +ToolWindow -Caption -DPIScale +E0x08000000", "URW Panel")
    gu.BackColor := EDITING ? "3A1F2B" : PAINTING ? "1F2E3A" : "12161C"
    gu.MarginX := 0
    gu.MarginY := 0
    gu.SetFont("s" FS " bold", "Segoe UI")

    y := PAD
    for rowIds in HeaderRows {
        x := PAD
        for id in rowIds {
            AddCell(gu, x, y, BW, BH, DEF[id])
            x += BW + GAP
        }
        y += BH + GAP
    }

    StatusTxt := gu.Add("Text", Format("x{} y{} w{} h{} +0x200 Background12161C cE6EDF3", PAD, y, PW - 2 * PAD, BH), "")
    StatusTxt.SetFont("s" FS " bold", "Segoe UI")
    y += BH + GAP

    ; paleta del modo colores, debajo de la línea de estado
    if PAINTING {
        nSw := PALETTE.Length + 1
        perRow := Ceil(nSw / PAL_ROWS)
        swW := (PW - 2 * PAD - (perRow - 1) * GAP) / perRow
        swH := Round(BH * PAL_H)
        Loop nSw {
            i := A_Index - 1
            sx := PAD + Round(Mod(i, perRow) * (swW + GAP))
            sy := y + (i // perRow) * (swH + GAP)
            bg := (i = 0) ? COL["emp"][1] : PALETTE[i]
            lb := (BRUSH = i) ? "✓" : (i = 0) ? "↺" : ""
            t := gu.Add("Text", Format("x{} y{} w{} h{} +0x200 Center Background{} c{}", sx, sy, Round(swW), swH, bg, Contrast(bg)), lb)
            t.SetFont("s" Min(FS + 5, 16) " bold", "Segoe UI")
            BTN[t.Hwnd] := {id: "", act: "pal", pi: i, grp: "sys", span: 1}
        }
        y += PAL_ROWS * (swH + GAP)
    }

    rowY := []
    for r, f in rowF {
        rowY.Push(y)
        y += Round(BH * f) + GAP
    }
    for id, p in POS {
        d := DEF[id]
        w := d.span * BW + (d.span - 1) * GAP
        sel := IsObject(SELP) && SELP.id = id
        AddCell(gu, PAD + (p.c - 1) * (BW + GAP), rowY[p.r], w, Round(BH * rowF[p.r]), d, sel)
    }
    if EDITING {
        Loop nRows {
            r := A_Index
            Loop COLS {
                c := A_Index
                if (Owner(r, c) != "") {
                    continue
                }
                e := {id: "", r: r, c: c, span: 1, big: 0, emo: false, act: "", grp: "emp"}
                sel := IsObject(SELP) && SELP.id = "" && SELP.r = r && SELP.c = c
                AddCell(gu, PAD + (c - 1) * (BW + GAP), rowY[r], BW, Round(BH * rowF[r]), e, sel)
            }
        }
    }

    totalH := y - GAP + PAD
    px := (SIDE = "L") ? 0 : scrW - PW
    py := Max(0, (scrH - totalH) // 2)
    old := G
    G := gu
    gu.Show(Format("NoActivate x{} y{} w{} h{}", px, py, PW, totalH))
    try WinSetTransparent(OPACITY, "ahk_id " gu.Hwnd)
    if IsObject(old)
        old.Destroy()
    ShowStatus()
}

AddCell(gu, x, y, w, h, d, selected := false) {
    if (selected)
        clr := COL["sel"]
    else if (d.id = "")
        clr := COL["emp"]
    else
        clr := ColorOf(d)
    label := (d.id = "") ? "·" : Lbl(d)
    t := gu.Add("Text", Format("x{} y{} w{} h{} +0x200 Center Background{} c{}", x, y, w, h, clr[1], clr[2]), label)
    face := (USE_EMOJI && d.emo) ? "Segoe UI Emoji" : "Segoe UI"
    if (StrLen(label) = 1)
        sz := Min(FS + 5, 18)
    else if (d.span > 1 || d.big > 0)
        sz := FS + d.big
    else
        sz := FITS.Has(label) ? Min(FS, FITS[label]) : FS
    if (sz != FS || face != "Segoe UI")
        t.SetFont("s" sz " bold", face)
    BTN[t.Hwnd] := d
    return t
}

ShowStatus() {
    if !IsObject(StatusTxt)
        return
    ; MSGGRP puede ser un grupo ("sys", "sel"...) o directamente un par [fondo, texto]
    if IsObject(MSGGRP)
        clr := MSGGRP
    else if (MSGGRP != "" && COL.Has(MSGGRP))
        clr := COL[MSGGRP]
    else
        clr := ["12161C", "E6EDF3"]
    try {
        StatusTxt.Opt("+Background" . clr[1])
        StatusTxt.SetFont("c" . clr[2])
    }
    StatusTxt.Text := " " . (MSG != "" ? MSG : U("ready"))
    try StatusTxt.Redraw()
}

SetStatus(text, grp := "") {
    global MSG, MSGGRP
    MSG := text
    MSGGRP := grp
    ShowStatus()
}

; Lengüeta que queda en el borde de la pantalla cuando el panel está oculto
TABW := 26
TABH := 96
TabX() {
    return (SIDE = "L") ? 0 : scrW - TABW
}
MakeTab() {
    global TG, TABBTN
    TG := Gui("+AlwaysOnTop +ToolWindow -Caption -DPIScale +E0x08000000", "URW Tab")
    TG.BackColor := "12161C"
    TG.MarginX := 0
    TG.MarginY := 0
    TG.SetFont("s12 bold", "Segoe UI")
    t := TG.Add("Text", Format("x0 y0 w{} h{} +0x200 Center Background3B4A6B cFFFFFF", TABW, TABH), "☰")
    TABBTN[t.Hwnd] := {id: "_tab", act: "show", span: 1, grp: "sys"}
}

; ---------- Arranque ----------
BuildGui()
MakeTab()

A_IconTip := "Panel UnReal World"
A_TrayMenu.Add()
A_TrayMenu.Add(U("tray"), TogglePanel)
A_TrayMenu.Add(U("traysd"), SwitchSide)
A_TrayMenu.Default := U("tray")

; ---------- Clic con el mouse ----------
; Atajo de mouse (y no eventos de controles) para poder repetir al mantener apretado.
#HotIf MouseOverPanel()
~LButton::PanelClick()
#HotIf

; Clic central = Esc (solo con la ventana del juego activa)
#HotIf MBUTTON_ESC && (GAME_WIN = "" || WinActive(GAME_WIN))
MButton::DoKey(DEF["ESC"])
#HotIf

^!p::TogglePanel()
^!l::SwitchSide()

MouseOverPanel() {
    MouseGetPos(, , &win)
    return (IsObject(G) && win = G.Hwnd) || (IsObject(TG) && win = TG.Hwnd)
}

PanelClick(*) {
    MouseGetPos(, , , &ctl, 2)
    if (!ctl)
        return
    if BTN.Has(ctl)
        d := BTN[ctl]
    else if TABBTN.Has(ctl)
        d := TABBTN[ctl]
    else
        return
    if (d.act != "") {
        KeyWait("LButton")
        RunAct(d)
        return
    }
    if PAINTING {
        KeyWait("LButton")
        PaintClick(d, ctl)
        return
    }
    if EDITING {
        KeyWait("LButton")
        if (SubStr(d.id, 1, 2) = "H_")
            SetStatus(U("keysoff"), "sys")
        else
            EditClick(d)
        return
    }
    DoKey(d)
    if (d.rep && !d.conf) {
        if !KeyWait("LButton", "T" Format("{:.2f}", REPEAT_FIRST / 1000)) {
            while GetKeyState("LButton") {
                DoKey(d)
                Sleep(REPEAT_EVERY)
            }
        }
    }
}

DoKey(d) {
    if (d.conf) {
        KeyWait("LButton")
        prev := WinExist("A")
        q := Tip(d) . "?"
        if (LANGI = 1)
            q := "¿" . q
        r := MsgBox(q, U("confirm"), "YesNo Icon? 262144")
        if prev {
            WinActivate("ahk_id " prev)
            WinWaitActive("ahk_id " prev, , 1)
        }
        if (r != "Yes")
            return
    }
    if (TARGET_WIN != "" && !WinActive(TARGET_WIN)) {
        WinActivate(TARGET_WIN)
        WinWaitActive(TARGET_WIN, , 1)
    }
    switch SEND_MODE {
        case "Input": SendInput(d.snd)
        case "Play": SendPlay(d.snd)
        default: SendEvent(d.snd)
    }
    txt := Tip(d)
    if (StrLen(txt) > 26)
        txt := SubStr(txt, 1, 25) . "…"
    SetStatus(txt . (d.shown != "" ? "  →  " . d.shown : ""), ColorOf(d))
}

; ---------- Acciones del panel ----------
RunAct(d) {
    global EDITING, PAINTING, BRUSH, CUST, SELP, LANGI, POS, MSG, MSGGRP
    switch d.act {
        case "lock":
            ; cerrado → mover → colores → cerrado
            if PAINTING {
                PAINTING := false
            } else if EDITING {
                EDITING := false
                PAINTING := true
            } else {
                EDITING := true
            }
            SELP := ""
            BRUSH := -1
            ModeMsg()
            BuildGui()
        case "pal":
            BRUSH := d.pi
            ModeMsg()
            BuildGui()
        case "side":
            SwitchSide()
        case "lang":
            LANGI := Mod(LANGI, LANGCODES.Length) + 1
            try IniWrite(LANGCODES[LANGI], INI_FILE, "panel", "lang")
            ModeMsg()
            ; los menús de la bandeja quedan en el idioma de arranque; el resto cambia al instante
            BuildGui()
        case "hide":
            TogglePanel()
        case "show":
            TogglePanel()
        case "exit":
            ExitApp()
        case "reset":
            if PAINTING {
                if (MsgBox(U("resetc"), U("confirm"), "YesNo Icon? 262144") = "Yes") {
                    CUST := Map()
                    SaveColors()
                    MSG := U("painted")
                    MSGGRP := "sel"
                    BuildGui()
                }
                return
            }
            if !EDITING {
                SetStatus(U("needlock"), "sys")
                return
            }
            if (MsgBox(U("resetq"), U("confirm"), "YesNo Icon? 262144") = "Yes") {
                POS := DefaultPos()
                try IniDelete(INI_FILE, "layout", "data")
                SELP := ""
                MSG := U("moved")
                MSGGRP := "sel"
                BuildGui()
            }
    }
}

; Mensaje de la línea de estado según el modo del candado
ModeMsg() {
    global MSG, MSGGRP
    if EDITING {
        MSG := U("pick1")
        MSGGRP := "sel"
    } else if PAINTING {
        MSG := (BRUSH >= 0) ? U("paint2") : U("paint1")
        MSGGRP := (BRUSH > 0) ? [PALETTE[BRUSH], Contrast(PALETTE[BRUSH])] : "sel"
    } else {
        MSG := ""
        MSGGRP := ""
    }
}

; ---------- Modo colores: pintar el botón tocado con el color elegido ----------
PaintClick(d, hwnd) {
    if (d.id = "")
        return
    if (BRUSH < 0) {
        SetStatus(U("nobrush"), "sel")
        return
    }
    if (BRUSH = 0) {
        if CUST.Has(d.id)
            CUST.Delete(d.id)
    } else {
        CUST[d.id] := PALETTE[BRUSH]
    }
    SaveColors()
    clr := ColorOf(d)
    try {
        c := GuiCtrlFromHwnd(hwnd)
        c.Opt("+Background" . clr[1])
        c.SetFont("c" . clr[2])
        c.Redraw()
    }
    SetStatus(U("painted"), clr)
}

SwitchSide(*) {
    global SIDE
    SIDE := (SIDE = "L") ? "R" : "L"
    try IniWrite(SIDE, INI_FILE, "panel", "side")
    if IsObject(G)
        G.Move(SIDE = "L" ? 0 : scrW - PW)
    if IsObject(TG)
        TG.Move(TabX())
}

TogglePanel(*) {
    global PANELVIS
    if PANELVIS {
        G.Hide()
        TG.Show(Format("NoActivate x{} y{} w{} h{}", TabX(), (scrH - TABH) // 2, TABW, TABH))
        try WinSetTransparent(OPACITY, "ahk_id " TG.Hwnd)
    } else {
        TG.Hide()
        G.Show("NoActivate")
    }
    PANELVIS := !PANELVIS
}

; ---------- Modo edición: intercambiar botones de lugar ----------
PieceOf(d) {
    if (d.id != "") {
        p := POS[d.id]
        return {id: d.id, r: p.r, c: p.c}
    }
    return {id: "", r: d.r, c: d.c}
}

PieceSpan(pc) {
    return (pc.id = "") ? 1 : DEF[pc.id].span
}

EditClick(d) {
    global SELP, MSG, MSGGRP
    pc := PieceOf(d)
    if !IsObject(SELP) {
        SELP := pc
        MSG := U("pick2")
        MSGGRP := "sel"
        BuildGui()
        return
    }
    if (SELP.id = pc.id && (pc.id != "" || (SELP.r = pc.r && SELP.c = pc.c))) {
        SELP := ""
        MSG := U("pick1")
        MSGGRP := "sel"
        BuildGui()
        return
    }
    ok := SwapPieces(SELP, pc)
    SELP := ""
    if ok {
        SavePos()
        MSG := U("moved")
    } else {
        MSG := U("nofit")
    }
    MSGGRP := "sel"
    BuildGui()
}

; Piezas (botones o celdas vacías) dentro de una franja de una fila; false si alguna queda cortada
PiecesIn(r, c0, w) {
    list := []
    col := c0
    while (col <= c0 + w - 1) {
        o := Owner(r, col)
        if (o = "") {
            list.Push({id: "", r: r, c: col})
            col += 1
        } else {
            p := POS[o]
            if (p.c < c0 || p.c + DEF[o].span - 1 > c0 + w - 1)
                return false
            list.Push({id: o, r: r, c: p.c})
            col := p.c + DEF[o].span
        }
    }
    return list
}

SwapPieces(pa, pb) {
    sa := PieceSpan(pa)
    sb := PieceSpan(pb)
    if (sa = sb) {
        ; mismo tamaño: se intercambian las posiciones
        if (pa.id != "")
            POS[pa.id] := {r: pb.r, c: pb.c}
        if (pb.id != "")
            POS[pb.id] := {r: pa.r, c: pa.c}
        return true
    }
    big := (sa > sb) ? pa : pb
    small := (sa > sb) ? pb : pa
    wb := PieceSpan(big)
    if (big.r = small.r)
        return SwapSameRow(big, small)
    ; el botón ancho toma el lugar de las celdas que ocuparía; los desplazados llenan las que dejó libres
    c0 := Max(1, Min(small.c, COLS - wb + 1))
    disp := PiecesIn(small.r, c0, wb)
    if !IsObject(disp)
        return false
    col := big.c
    for pc in disp {
        if (pc.id != "")
            POS[pc.id] := {r: big.r, c: col}
        col += PieceSpan(pc)
    }
    POS[big.id] := {r: small.r, c: c0}
    return true
}

SwapSameRow(big, small) {
    r := big.r
    list := PiecesIn(r, 1, COLS)
    if !IsObject(list)
        return false
    ia := 0
    ib := 0
    for i, pc in list {
        if (pc.id = big.id && pc.c = big.c)
            ia := i
        if (pc.id = small.id && pc.c = small.c)
            ib := i
    }
    if (!ia || !ib)
        return false
    tmp := list[ia]
    list[ia] := list[ib]
    list[ib] := tmp
    col := 1
    for pc in list {
        if (pc.id != "")
            POS[pc.id] := {r: r, c: col}
        col += PieceSpan(pc)
    }
    return true
}
