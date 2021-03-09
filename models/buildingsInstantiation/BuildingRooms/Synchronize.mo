within BuildingRooms;
package Synchronize
  connector SynchronizeConnector
    Real do "Potential variable";
    flow Real done "Flow variable";
  end SynchronizeConnector;

  model SynchronizeBuilding
    SynchronizeConnector synchronize;
  end SynchronizeBuilding;

  model ObjectSynchronizer
    outer Building building;
    SynchronizeBuilding synBui;
  equation
  connect(building.synchronize, synBui.synchronize);
  end ObjectSynchronizer;
end Synchronize;
