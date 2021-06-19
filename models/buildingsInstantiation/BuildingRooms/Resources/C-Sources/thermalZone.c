#ifndef thermalZone_c
#define thermalZone_c

#include <string.h>
#include <stdbool.h>

#include "thermalZone.h"

static int nZon = 0; /* Number of zones  */
static bool buildingIsInstantiated = false;

void* ZoneAllocate(const char* name){
  Zone* ptrZone;

   /* Allocate zone and assign name */
  ptrZone = (Zone*) malloc(sizeof(Zone));
  ptrZone->name =
    malloc((strlen(name)+1) * sizeof(char));
  strcpy(ptrZone->name, name);
  /* Increment counter for zones */
  nZon++;

  ModelicaFormatMessage(
    "Allocated zone %s\n", name);
  return (void*) ptrZone;
}

void ZoneInitialize(
    void* object,
    double startTime,
    int* nZ){
    Zone* zone = (Zone*) object;
    *nZ = nZon;
    if (!buildingIsInstantiated){
      /* Here, the actual implementation
         constructs an FMU that
         is shared by all zones.
         This requires that all zones
         executed ZoneAllocate().
      */
        buildingIsInstantiated = true;
        ModelicaFormatMessage(
          "Initialized zone %s. Instantiated building, nZ = %d.\n",
          zone->name, nZon);
    }
    else{
        ModelicaFormatMessage(
          "Initialized zone %s, nZon = %d\n",
          zone->name, nZon);
    }
}

void ZoneExchange(
    void* object,
    double time,
    double T,
    double* tNext,
    double* Q_flow){
    Zone* zone = (Zone*) object;
    /* In the actual implementation,
       this is computed in an FMU.
    */
    *Q_flow = 283.15-T;
    *tNext = time + 1;
    ModelicaFormatMessage(
      "Exchanged with zone %s at time=%f, nZon = %d\n",
      zone->name, time, nZon);
}

void ZoneFree(void* object){
    Zone* zone = (Zone*) object;
    free(zone->name);
    free(zone);
}

#endif