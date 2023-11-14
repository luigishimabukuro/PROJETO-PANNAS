.MODEL SMALL

PULA_LINHA MACRO
    PUSH DX
    PUSH AX
    MOV DL, 10
    MOV AH, 02
    INT 21H
    POP AX
    POP DX
ENDM

PRINT MACRO
    PUSH AX
    MOV AH, 09
    INT 21H
    POP AX

ENDM

PREP_NOTA3X MACRO
        PUSH CX                      
        MOV CX, 3

        PUSH BX                     
        MOV SI, 15              

        POP BX                   
    ENDM

.STACK 0100h
.DATA
    DADOS db  5 dup(15, ?, 15 dup(' '),'$', 4 dup (?))
    msg1 db "INSIRA O NOME DO ALUNO:$"
    msg2 db "INSIRA A NOTA DO ALUNO:$"
    MENU db 10,13,"Escolha uma opcao:"
        db 10,13,"1 - Editar Dados"
        db 10,13,"2 - Ver Tabela"
        db 10,13,"0 - Finalizar Programa$"
    PESQUISA db 10,13,"Escolha uma opcao:"
            db 10,13,"1 - Editar Notas"
            db 10,13,"2 - Editar Nomes"
            db 10,13,"0 - Retornar ao Menu Principal$", 10,13
    PESQUISA_GERAL db 15, ?, 15 dup('$')

.CODE

MAIN PROC
    MOV AX ,@DATA
    MOV DS, AX
    MOV ES, AX

    XOR BX, BX
    MOV CX, 5

LEITURA_NOME:
    XOR SI, SI
    
    PULA_LINHA

    LEA DX, msg1
    PRINT
    
    LEA DX, DADOS + BX
    CALL LEH_NOME
    
    PULA_LINHA

    PREP_NOTA3X

LEITURA_NOTA:

    LEA DX, msg2
    PRINT

    CALL LEH_NOTA

LOOP LEITURA_NOTA

    POP CX

    CALL MEDIA

    ADD BX, 22

LOOP LEITURA_NOME

CHAMADA_DE_MENU:

    PULA_LINHA

    LEA DX, MENU
    PRINT

    MOV AH, 01

    SELECIONAR_OPCAO:
    INT 21H

    CMP AL, '1'
    JZ EDITAR

    CMP AL, '2'
    JZ TABELA

    CMP AL, '0'
    JZ SAIR

    JMP SELECIONAR_OPCAO

SAIR:

    MOV AH, 4CH
    INT 21H

EDITAR:

    PULA_LINHA

    LEA DX, PESQUISA
    PRINT

    MOV AH, 01
    
    SELECIONAR_PESQUISA:

    INT 21H

    CMP AL, '1'
    JZ EDITAR_NOTA

    CMP AL, '2'
    JZ EDITAR_NOME

    CMP AL, '0'
    JZ CHAMADA_DE_MENU

    JMP SELECIONAR_PESQUISA

EDITAR_NOTA:

    LEA DX, PESQUISA_GERAL
    CALL LEH_NOTA
    INC DX

    CALL PESQUISA_NOTA
    JMP CHAMADA_DE_MENU

EDITAR_NOME:

    LEA DX, PESQUISA_GERAL
    CALL LEH_NOME
    INC DX

    CALL PESQUISA_NOME
    JMP CHAMADA_DE_MENU

TABELA:

    PULA_LINHA

    CALL IMPRIME_TABELA
    JMP CHAMADA_DE_MENU

MAIN ENDP


LEH_NOME PROC

    PUSH AX

    MOV AH, 0AH
    INT 21H

    POP AX

    RET

LEH_NOME ENDP

LEH_NOTA PROC

    PUSH BX

    LEA BX, DADOS + BX
    CALL ENTRADA_NUM

    MOV [BX + SI], AL
    INC SI

    POP BX

    RET

LEH_NOTA ENDP

ENTRADA_NUM PROC
        
        PUSH SI
        PUSH BX
        XOR BX, BX                                 

    RECEBEDEC:
        MOV AH, 01                                  
        INT 21H                                     

        CMP AL, 13                                  
        JE ENTDECFIM                              

        CMP AL, '0'                               
        JB RECEBEDEC                            

        CMP AL, '9'                                
        JA RECEBEDEC                                

    DECPARABIN:
        XOR AH, AH                                 

        AND AL, 0FH                                 
        PUSH AX                                     

        MOV AX, 10                               
        MUL BX                                     
        POP BX                                     
        ADD BX, AX                                  

        JMP RECEBEDEC                               

    ENTDECFIM:
        MOV AX, BX                                  

        POP BX
        POP SI
        RET

ENTRADA_NUM ENDP

MEDIA PROC

    PREP_NOTA3X

    PUSH BX
    LEA BX, DADOS + BX

SOMA_DA_MEDIA:

    ADD AL, [BX + SI]
    INC SI

LOOP SOMA_DA_MEDIA

    PUSH BX
    XOR DX, DX

    MOV BX, 3
    DIV BX

    POP BX

    MOV [BX + SI], AL

    POP BX
    POP CX

    RET
MEDIA ENDP

IMPRIME_TABELA PROC 
    MOV DL, 'P'
    MOV AH,02
    INT 21H
    RET
IMPRIME_TABELA ENDP

PESQUISA_NOME PROC
    MOV DL, 'N'
    MOV AH,02
    INT 21H
    RET

PESQUISA_NOME ENDP

PESQUISA_NOTA PROC
    MOV DL, 'J'
    MOV AH,02
    INT 21H
    RET
PESQUISA_NOTA ENDP
END MAIN