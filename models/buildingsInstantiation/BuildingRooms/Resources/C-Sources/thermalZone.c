#ifndef thermalZone_c
#define thermalZone_c

#include <string.h>

#include "thermalZone.h"

static int nZon = 0;     /* Number of zones in building */

void* ZoneAllocate(const char* name){
  Zone* ptrZone;

   /* Allocate zone and assign name */
  ptrZone = (Zone*) malloc(sizeof(Zone));
  ptrZone->name = malloc((strlen(name)+1) * sizeof(char));
  strcpy(ptrZone->name, name);
  nZon++;

  ModelicaFormatMessage("Allocated zone %s\n", name);
  return (void*) ptrZone;
}

void ZoneInitialize(void* object, double startTime, int* nZ){
    Zone* zone = (Zone*) object;
    *nZ = nZon;
    ModelicaFormatMessage("Initialized zone %s, nZon = %d\n", zone->name, nZon);
}

void ZoneExchange(void* object, double time, double T, double* tNext, double* Q_flow){
    Zone* zone = (Zone*) object;
    *Q_flow = 283.15-T;
    *tNext = time + 1;
    ModelicaFormatMessage("Exchanged with zone %s at time=%f, nZon = %d\n", zone->name, time, nZon);
}

void ZoneFree(void* object){
    Zone* zone = (Zone*) object;
    ModelicaFormatMessage("Freeing memory for %s\n", zone->name);
}

#endif