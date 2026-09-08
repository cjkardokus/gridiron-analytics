// Command api is the gridiron-analytics HTTP API server.
//
// This is a scaffold: a minimal server proving the module builds, runs,
// and responds. Route handlers, database access, and business logic are
// added in later branches.
package main

import (
	"log"
	"net/http"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", healthzHandler)

	addr := ":8080"
	log.Printf("gridiron-analytics api listening on %s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatal(err)
	}
}

func healthzHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte("ok"))
}
