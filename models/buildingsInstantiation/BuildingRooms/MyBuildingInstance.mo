within BuildingRooms;
model MyBuildingInstance
  "Building with two thermal zones, e.g., nZ=2"
  inner Building building;
  ThermalZone t1;
  ThermalZone t2;
end MyBuildingInstance;
