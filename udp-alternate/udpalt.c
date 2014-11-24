#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define PORT "5858"

/* number of hosts to connect to */
#define NUMHOSTS 2

#define SENDLEN 1000

int main (int argc, char **argv) {
    int sockfds[NUMHOSTS];
    char sendme[SENDLEN];
    struct addrinfo hints;
    struct addrinfo *result[NUMHOSTS], *rp;
    int retval;
    unsigned i;
    size_t ndata;
    int interpktdelay;
    unsigned update_every;

    if (argc != (NUMHOSTS + 2)) {
        fprintf(stderr, "Usage: %s", argv[0]);
        for (i = 0; i < NUMHOSTS; ++i)
            fprintf(stderr, " <host #%u>", i+1);
        fprintf(stderr, " <delay_usec>\n"
                "\tdelay_usec: delay between each set of %u packets\n",
                NUMHOSTS);
        exit(EXIT_FAILURE);
    }

    interpktdelay = atoi(argv[NUMHOSTS + 1]);
    update_every = 200000 / interpktdelay;

    bzero(&hints, sizeof(hints));
    hints.ai_family = AF_INET;       /* IPv4 */
    hints.ai_socktype = SOCK_DGRAM;  /* UDP */

    for (i = 0; i < NUMHOSTS; ++i) {
        fprintf(stderr, "Establishing socket to %s port %s/udp\n",
                argv[i+1], PORT);
        retval = getaddrinfo(argv[i+1], PORT, &hints, &result[i]);
        if (retval != 0) {
            fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(retval));
            exit(EXIT_FAILURE);
        }

        for (rp = result[i]; rp != NULL; rp = rp->ai_next) {
            sockfds[i] = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
            if (sockfds[i] == -1) {
                fprintf(stderr, "could not establish socket: %s\n",
                        strerror(errno));
                exit(EXIT_FAILURE);
            }
        }
    }

    for (i = 0; i < SENDLEN; ++i) {
        sendme[i] = 'A';
    }

    /* Do work here: send alternating datagrams */
    for (ndata = 0; ; ++ndata) {
        for (i = 0; i < NUMHOSTS; ++i) {
            sendto(sockfds[i], sendme, SENDLEN, 0,
                    result[i]->ai_addr, result[i]->ai_addrlen);
        }

        if (!(ndata % update_every)) {
            printf("\r%dB * %lu", SENDLEN, ndata);
            fflush(stdout);
        }

        usleep(interpktdelay);
    }

    return 0;
}
