within BuildingRooms;
model Building
  "Model that declares a building"
  Synchronize.SynchronizeConnector synchronize;
  Real synchronization_done = synchronize.done;
  Real isSynchronized;
equation
  synchronize.do = 0;
algorithm
  isSynchronized := synchronization_done;
end Building;
