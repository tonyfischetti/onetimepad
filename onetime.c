/* Copyright (c) 2017, Tony Fischetti
 *
 * MIT License, http://www.opensource.org/licenses/mit-license.php
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a 
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, 
 * and/or sell copies of the Software, and to permit persons to whom the 
 * Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 * DEALINGS IN THE SOFTWARE.
 * 
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <libgen.h>

const int BLOCK_SIZE = 500;


const char *header_text = 
    "\nonetime v0.3 -- one-time pad encryption on files (byte by byte)\n";

const char *usage_text =
    "usage: onetime [-hed | -o output] input-file one-time-pad\n";



void add(size_t howmany, int *one, int *two, int *ciphertext){
    for(int i = 0; i < howmany; i++){
        *(ciphertext+i) = *(one+i) + *(two+i);
    }
}

void sub(size_t howmany, int *one, int *two, int *ciphertext){
    for(int i = 0; i < howmany; i++){
        *(ciphertext+i) = *(one+i) - *(two+i);
    }
}
void swap(char *str1, char *str2){
  char *temp = str1;
  str1 = str2;
  str2 = temp;
}  



int main(int argc, char** argv){
    int             CURRENT_INS[BLOCK_SIZE];
    int             CURRENT_ONES[BLOCK_SIZE];
    unsigned long   IN_LEN;
    unsigned long   ONE_LEN;
    int             CURRENT_CIPHERS[BLOCK_SIZE];
    void            (*PROC_PNT)(size_t, int*, int*, int*);
    int             ONE_BIGGER = 0;
    char*           IN_FN;
    char*           ONE_FN;
    char*           OUT_FN = "this";  // gets overrided
    /* char*           OUT_FN = '';  // gets overrided */
    /* char*           OUT_FN; */
    int             OUT_SPECIFIED = 0;
    int             DECRYPT_SPECIFIED = 0;
    int             ENCRYPT_SPECIFIED = 0;

    // default is to encrypt
    PROC_PNT = &add;

    // for option parsing
    int c;

    static struct option long_options[] =
    {
        {"encrypt", no_argument, 0, 'e'},
        {"decrypt", no_argument, 0, 'd'},
        {"output",  required_argument, 0, 'o'},
        {0, 0, 0, 0}
    };
    
    int long_index =0;
    while ((c = getopt_long(argc, argv,"hdeo:", 
                   long_options, &long_index )) != -1) {
        switch (c) {
             case 'e':
                 if(DECRYPT_SPECIFIED){
                     fprintf(stderr, "Must be either encryption or decryption\n");
                     exit(EXIT_FAILURE);
                 }
                 ENCRYPT_SPECIFIED = 1;
                 PROC_PNT = &add;
                 break;
             case 'd':
                 if(ENCRYPT_SPECIFIED){
                     fprintf(stderr, "Must be either encryption or decryption\n");
                     exit(EXIT_FAILURE);
                 }
                 DECRYPT_SPECIFIED = 1;
                 PROC_PNT = &sub;
                 OUT_FN = "original";
                 break;
             case 'o':
                 OUT_FN = optarg;
                 OUT_SPECIFIED = 1;
                 break;
             case 'h':
                printf("%s", header_text);
                printf("%s\n", usage_text);
                exit(EXIT_FAILURE);
            case '?':
                printf("%s\n", usage_text);
                exit(EXIT_FAILURE);
             default:
                 fprintf(stderr, usage_text);
                 exit(EXIT_FAILURE);
        }
    }

    if(optind+2 != argc){
        fprintf(stderr, "missing files\n");
        fprintf(stderr, usage_text);
        exit(EXIT_FAILURE);
    }
    IN_FN = argv[optind++];
    ONE_FN = argv[optind++];

    if(DECRYPT_SPECIFIED==0 && ENCRYPT_SPECIFIED==0)
        ENCRYPT_SPECIFIED = 1;

    // if output file isn't specifies
    // let's use good defaults
    if(OUT_SPECIFIED==0){
        if(ENCRYPT_SPECIFIED){
            char* base = basename(IN_FN);
            int length = strlen(base);
            char tmp[length+5];
            strcpy(tmp, base);
            strcat(tmp, ".pad");
            OUT_FN = (char*) malloc(strlen(tmp)*sizeof(char)+1);
            strcpy(OUT_FN, tmp);
        }
    }

    FILE* IN_FH = fopen(IN_FN, "rb");
    FILE* ONE_FH = fopen(ONE_FN, "rb");
    FILE* OUT_FH = fopen(OUT_FN, "wb"); /////

    // getting size of input file
    fseek(IN_FH, 0L, SEEK_END);
    IN_LEN = ftell(IN_FH);
    fseek(IN_FH, 0, SEEK_SET);

    // getting size of one time pad
    fseek(ONE_FH, 0L, SEEK_END);
    ONE_LEN = ftell(ONE_FH);
    fseek(ONE_FH, 0, SEEK_SET);

    // check if one time pad is smaller than input file
    if(IN_LEN > ONE_LEN){
        ONE_BIGGER = 1;
        printf("Warning: one time pad is smaller than input file. Will recycle\n");
    }

    for(int i=0; i < IN_LEN; i+=BLOCK_SIZE){
        int howmany = fread(CURRENT_INS, sizeof(char), BLOCK_SIZE, IN_FH);
        int howmanyone = fread(CURRENT_ONES, sizeof(char), BLOCK_SIZE, ONE_FH);
        if(ONE_BIGGER){
            if(howmanyone < howmany){
                int thediff = howmany-howmanyone;
                fseek(ONE_FH, 0, SEEK_SET);
                int howaboutnow = fread(&CURRENT_ONES[howmanyone], sizeof(char),
                                        thediff, ONE_FH);
                if((howaboutnow+howmanyone) < howmany){
                    fprintf(stderr, "fatal error: one time pad is too small\n");
                    exit(1);
                }
            }
        }

        (*PROC_PNT)(howmany, CURRENT_INS, CURRENT_ONES, CURRENT_CIPHERS);

        fwrite(CURRENT_CIPHERS, sizeof(char), howmany, OUT_FH);
        if(howmany<BLOCK_SIZE)
            break;
    }

    // close the files
    fclose(IN_FH);
    fclose(ONE_FH);
    fclose(OUT_FH);

    return 0;
}
