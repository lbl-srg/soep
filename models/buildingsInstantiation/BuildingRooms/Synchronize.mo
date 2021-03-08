within BuildingRooms;
package Synchronize
  connector SynchronizeConnector "Connector to synchronize Spawn objects"
    Real do "Potential variable";
    flow Real done "Flow variable";
  end SynchronizeConnector;

  model SynchronizeBuilding "Model to synchronize the Spawn objects"
    SynchronizeConnector synchronize "Connector that is used to synchronize objects";
  end SynchronizeBuilding;

  model ObjectSynchronizer "Block that synchronizes an object"
    outer Building building;
  SynchronizeBuilding synBui;
  equation
  connect(building.synchronize, synBui.synchronize);
  end ObjectSynchronizer;
end Synchronize;
