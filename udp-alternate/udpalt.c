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

    if (argc != (NUMHOSTS+1)) {
        fprintf(stderr, "Usage: %s", argv[0]);
        for (i = 0; i < NUMHOSTS; ++i)
            fprintf(stderr, " <host #%u>", i+1);
        fprintf(stderr, "\n");
        exit(EXIT_FAILURE);
    }

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

        if (!(ndata % 500)) {
            printf("\r%dB * %d", SENDLEN, ndata);
            fflush(stdout);
        }
        usleep(1000);
    }

    return 0;
}
