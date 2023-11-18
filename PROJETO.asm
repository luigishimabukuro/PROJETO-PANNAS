.MODEL SMALL

PULA_LINHA MACRO

    ; Salva os valores de DX e AX para pular uma linha e depois os retorna

    PUSH DX 
    PUSH AX
    MOV DL, 10
    MOV AH, 02
    INT 21H
    POP AX
    POP DX
ENDM

PRINT MACRO

    ; Salva o valor de AX e imprime o que foi colocado em DX para imprimir uma string. Depois, retorna o valor de AX

    PUSH AX
    MOV AH, 09
    INT 21H
    POP AX

ENDM

ESPACO MACRO

    ; Guarda os valores de AX e DX para dar um espaçamento pela tabela usando o símbolo do sifrão, depois os retorna

    PUSH AX
    PUSH DX
    MOV AH, 02
    MOV DL, "$"
    INT 21H

    POP DX
    POP AX

ENDM

RETIRA_ENTER MACRO

    ; Guarda os valores de BX e DX, depois recebe o numero de caracteres digitados menos o ENTER, que se transforma em uma sifrão para não interferir nos valores da string ou da matriz, depois retorna os registradores

    PUSH BX
    PUSH DX

    INC BX
    MOV DL, [BX]
    INC BX
    ADD BX, DX
    MOV DL, '$'

    MOV [BX], DL

    POP DX
    POP BX

ENDM

.STACK 0100h

.DATA
    DADOS db  5 dup(15, ?, 15 dup('$'),'$', 4 dup (?)) ; Numero de caracteres por nome = 15; ? = Numeros de caracteres digiados; 15 dup('$') = Preenche o que não foi digitado com sifrão; 4 dup (?) = Guarda os valores das provas e da média em binário

    msg1 db "INSIRA O NOME DO ALUNO:$"

    msg2 db "INSIRA A NOTA DO ALUNO:$"

    MENU db 10,13,"O que deseja fazer?"
         db 10,13,"1 - Editar Dados"
         db 10,13,"2 - Ver Tabela"
         db 10,13,"0 - Finalizar Programa$"
        
    PESQUISA db 10,13,"O que deseja editar?"
             db 10,13,"1 - Editar Notas"
             db 10,13,"2 - Editar Nomes"
             db 10,13,"0 - Retornar ao Menu Principal$", 10,13

    PESQUISA_GERAL db 15, ?, 15 dup('$')

    LIMPA_VETOR db 15 dup('$')

    EDITA_NOTA db "Que prova deseja editar"
            db 10,13,"1 - P1"
            db 10,13,"2 - P2"
            db 10,13,"3 - P3$"
    OPCAO db "Escolha uma opcao:$"

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

        PUSH CX                      
        MOV CX, 3

        PUSH BX                     
        MOV SI, 15              

        POP BX             

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

        PULA_LINHA
    
        LEA DX, OPCAO
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

                EDITAR:

                    PULA_LINHA

                    LEA DX, PESQUISA
                    PRINT

                    PULA_LINHA

                    LEA DX, OPCAO
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
                            CALL LEH_NOME
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

                SAIR:

                    MOV AH, 4CH
                    INT 21H

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

    PUSH CX                      
    MOV CX, 3

    PUSH BX                     
    MOV SI, 15              

    POP BX             

    XOR AX, AX

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

    LEA BX, DADOS
    MOV CX, 5

    SAIDA_DE_LINHA:

        MOV SI, 18
        MOV DX, BX
        ADD DX, 2

        MOV AH, 09
        INT 21H

        ESPACO

        PUSH CX
        MOV CX, 4

        SAIDA_DE_NOTA:
    
            CALL SAIDA_DECIMAL

            ESPACO

            INC SI

        LOOP SAIDA_DE_NOTA

        POP CX
        ADD BX, 22
        PULA_LINHA

    LOOP SAIDA_DE_LINHA

    RET

IMPRIME_TABELA ENDP

SAIDA_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR AX, AX
    MOV AL, [BX+SI]

    DIVISAO:

        XOR CX, CX
        MOV BX, 10

        NUMEROS:

            XOR DX, DX

            DIV BX
            PUSH DX
            INC CX

            OR AX, AX

            JNZ NUMEROS

            MOV AH, 02

            IMPRIMIR_NUMEROS:

                POP DX
                OR DX, 30H
                INT 21H

            LOOP IMPRIMIR_NUMEROS

    POP DX
    POP CX
    POP BX
    POP AX

    RET

SAIDA_DECIMAL ENDP

PESQUISA_NOME PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    PUSH SI

    XOR AL, AL

    MOV CX, 5

    XOR BX, BX

    PESQUISA_DE_NOME:
        PUSH DX
        PUSH CX

        LEA SI, PESQUISA_GERAL + 2
        LEA DI, DADOS + BX
        ADD DI, 2

        PUSH BX
        MOV BX, DX
        MOV CL, [BX]
        POP BX

        REPE CMPSB
        JNZ STR_NAO_EH_IGUAL

        LEA SI, LIMPA_VETOR

        LEA DI, DADOS + BX
        ADD DI, 2

        PUSH BX
        MOV BX, DX
        MOV CL, [BX]
        POP BX

        REP MOVSB

        LEA DX, DADOS + BX
        CALL LEH_NOME

        PUSH BX
        LEA BX, DADOS + BX

        RETIRA_ENTER

        POP BX

        JMP PROXIMA_LINHA

        STR_NAO_EH_IGUAL:

            INC AL

        PROXIMA_LINHA:

            ADD BX, 22
            POP CX
            POP DX

    LOOP PESQUISA_DE_NOME

    CMP AL, 5
    JNE FINAL_DA_PESQUISA


    FINAL_DA_PESQUISA:

        POP SI
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX

    RET

PESQUISA_NOME ENDP

PESQUISA_NOTA PROC
   
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    PUSH SI

    XOR AL, AL
                
    MOV CX, 5
                
    XOR BX, BX

    PESQUISA_DE_NOTA:

        PUSH DX

        PUSH CX

        LEA SI, PESQUISA_GERAL + 2

        LEA DI, DADOS + BX

        ADD DI, 2
                    
        PUSH BX
        MOV BX, DX
        MOV CL, [BX]
        POP BX
                        
        REPE CMPSB
        JNZ NOT_EQUAL_NOME
                    
        PUSH BX

        LEA BX, TABELA + BX

        LEA DX, EDITA_NOTA

        PRINT

        PULA_LINHA

        MOV AH, 01
        XOR SI, SI

        SELECIONAR_PROVA:

            INT 21H                                     

            CMP AL, '1'                                 
            JE P1                             

            CMP AL, '2'                                 
            JE P2                             

            CMP AL, '3'                                 
            JE P3       

        JMP SELECIONAR_PROVA                         
            
            P1:
            ADD SI, 19
            JMP RECEBEPROVA

            P2:
            ADD SI, 20
            JMP RECEBEPROVA

            P3:
            ADD SI, 21

            RECEBEPROVA:

                CALL ENTRADA_NUM
                MOV [BX+SI], AL
                POP BX
                CALL MEDIA
                                
            JMP PESQUISA_NOTA_FIM

            NOT_EQUAL_NOME:

                INC AL

            PESQUISA_NOTA_FIM:

                ADD BX, 22
                POP CX
                POP DX

    LOOP PESQUISA_DE_NOTA
                    
        CMP AL, 5
        JNE FINAL
                    
    FINAL:                
        POP SI
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX

    RET

PESQUISA_NOTA ENDP

END MAIN