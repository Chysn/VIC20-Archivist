* = $a000

;            .byte $42                   ; Uncomment to disable autostart
Autostart:  .byte $03,$20
            .byte $5b,$ff
            .byte $41,$30,$c3,$c2,$cd