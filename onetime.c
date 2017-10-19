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

const int BLOCK_SIZE = 500;


const char *header_text = 
    "\nonetime v0.2 -- one-time pad encryption on files (byte by byte)\n";

const char *usage_text =
    "usage: onetime [-hed | -o output] input-file one-time-pad\n";


/* int add(int one, int two){ */
/*     return(one + two); */
/* } */
/*  */
/* int sub(int one, int two){ */
/*     return(one - two); */
/* } */

void add(size_t howmany, int *one, int *two, int *ciphertext){
    // is it less than or equal to block size!!???
    for(int i = 0; i < howmany; i++){
        *(ciphertext+i) = *(one+i) + *(two+i);
    }
}

void sub(size_t howmany, int *one, int *two, int *ciphertext){
    // is it less than or equal to block size!!???
    for(int i = 0; i < howmany; i++){
        *(ciphertext+i) = *(one+i) - *(two+i);
    }
}


int main(int argc, char** argv){
    /* int             CURRENT_IN = 0; */
    int             CURRENT_INS[BLOCK_SIZE];
    /* char             CURRENT_INS[BLOCK_SIZE]; */
    /* int              CURRENT_ONE = 0; */
    int             CURRENT_ONES[BLOCK_SIZE];
    /* char             CURRENT_ONES[BLOCK_SIZE]; */
    unsigned long   IN_LEN;
    unsigned long   ONE_LEN;
    /* int             CURRENT_CIPHER = 0; */
    int             CURRENT_CIPHERS[BLOCK_SIZE];
    /* char             CURRENT_CIPHERS[BLOCK_SIZE]; */
    void            (*PROC_PNT)(size_t, int*, int*, int*);
    int             ONE_BIGGER = 0;
    char*           IN_FN;
    char*           ONE_FN;
    char*           OUT_FN = "ciphertext";

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
                 PROC_PNT = &add;
                 break;
             case 'd':
                 PROC_PNT = &sub;
                 OUT_FN= "original";
                 break;
             case 'o':
                 OUT_FN = optarg;
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

    FILE*           IN_FH = fopen(IN_FN, "rb");
    FILE*           ONE_FH = fopen(ONE_FN, "rb");
    FILE*           OUT_FH = fopen(OUT_FN, "wb");

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

    // loop through the input file and encrypt it
    // it used a function pointer that perform
    // either ENcryption or DEcryption based on
    // user specification
    /* for(int i=0; i < IN_LEN; i++){ */
    /*     if(ONE_BIGGER){ */
    /*         // if we've reached the end of the */
    /*         // one time pad, start over */
    /*         if(feof(ONE_FH)){ */
    /*             fseek(ONE_FH, 0, SEEK_SET); */
    /*         } */
    /*     } */
    /*     CURRENT_IN  = fgetc(IN_FH); */
    /*     CURRENT_ONE = fgetc(ONE_FH); */
    /*     CURRENT_CIPHER = (*PROC_PNT)(CURRENT_IN, CURRENT_ONE); */
    /*     fputc(CURRENT_CIPHER, OUT_FH); */
    /* } */

    for(int i=0; i < IN_LEN; i+=BLOCK_SIZE){
        /* CURRENT_IN  = fgetc(IN_FH); */

        int howmany = fread(CURRENT_INS, sizeof(char), BLOCK_SIZE, IN_FH);
        int howmanyone = fread(CURRENT_ONES, sizeof(char), BLOCK_SIZE, ONE_FH);
        if(ONE_BIGGER){
            if(howmanyone < howmany){
                int thediff = howmany-howmanyone;
                fseek(ONE_FH, 0, SEEK_SET);
                int howaboutnow = fread(&CURRENT_ONES[howmanyone], sizeof(char),
                                        thediff, ONE_FH);
                /* printf("actual:          %d\n", howmany); */
                /* printf("was:             %d\n", howmanyone); */
                /* printf("now:             %d\n", howaboutnow); */
                /* printf("needed:          %d\n", thediff); */
                /* printf("alltogether:     %d\n", howaboutnow+howmanyone); */
                /* printf("\n"); */
                /* fflush(stdout); */
                if((howaboutnow+howmanyone) < howmany){
                    fprintf(stderr, "fatal error: one time pad is too small\n");
                    exit(1);
                }
            }
        }


        // need to change
        (*PROC_PNT)(howmany, CURRENT_INS, CURRENT_ONES, CURRENT_CIPHERS);

        /* for(int i = 0; i < howmany; i++){ */
        /*     printf("%d-%d\n", CURRENT_INS[i], CURRENT_ONES[i]); */
        /* } */
        /* printf("\n"); */
        /* fflush(stdout); */
        /* printf("\n"); */
        /* printf("\n"); */
        /* for(int i = 0; i < BLOCK_SIZE; i++){ */
        /*     printf("%c", CURRENT_ONES[i]); */
        /* } */
        /* printf("\n"); */

        fwrite(CURRENT_CIPHERS, sizeof(char), howmany, OUT_FH);
        /* printf("read %d bytes\n", howmany); */
        if(howmany<BLOCK_SIZE)
            break;
        /* printf("going around again\n"); */
    }


    // close the files
    fclose(IN_FH);
    fclose(ONE_FH);
    fclose(OUT_FH);

    return 0;
}
