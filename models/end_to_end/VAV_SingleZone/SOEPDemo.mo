within ;
package SOEPDemo
  "Package containing models for SOEP demonstration and EnergyPlus comparison."

  package ThermalEnvelope
    "Package containing models for the thermal envelope of the building"
    model SingleZoneFF
      "Single zone thermal envelope model based on 1ZoneUncontrolled.idf EnergyPlus example file"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      parameter Modelica.SIunits.Angle lat "Building latitude";
      parameter SOEPDemo.Constructions.WALL13
        Wall001 "Exterior wall facing south";
      parameter SOEPDemo.Constructions.WALL13
        Wall002 "Exterior wall facing east";
      parameter SOEPDemo.Constructions.WALL13
        Wall003 "Exterior wall facing north";
      parameter SOEPDemo.Constructions.WALL13
        Wall004 "Exterior wall facing west";
      parameter SOEPDemo.Constructions.FLOOR Flr001 "Floor";
      parameter SOEPDemo.Constructions.ROOF31 Roof001 "Roof";
      Buildings.ThermalZones.Detailed.MixedAir zone(
        redeclare package Medium = MediumA,
        AFlo=15.24*15.24,
        hRoo=4.572,
        nConExt=5,
        datConExt(layers={Wall001, Wall002, Wall003, Wall004, Roof001},
               A={15.24*4.572, 15.24*4.572, 15.24*4.572, 15.24*4.572, 15.24*15.24},
               til={Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Ceiling},
               azi={Buildings.Types.Azimuth.S, Buildings.Types.Azimuth.E, Buildings.Types.Azimuth.N, Buildings.Types.Azimuth.W, Buildings.Types.Azimuth.S}),
        nConExtWin=0,
        nConPar=0,
        nConBou=1,
        datConBou(layers={Flr001},
               A={15.24*15.24},
               til={Buildings.Types.Tilt.Floor}),
        nSurBou=0,
        linearizeRadiation = true,
        energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
        T_start = 273.15 + 0.98087577,
        intConMod=Buildings.HeatTransfer.Types.InteriorConvection.Temperature,
        extConMod=Buildings.HeatTransfer.Types.ExteriorConvection.TemperatureWind,
        lat(displayUnit="rad") = lat)
                              "Zone model"
        annotation (Placement(transformation(extent={{-20,-20},{20,20}})));

      Buildings.BoundaryConditions.WeatherData.Bus weaBus "Weather data"
        annotation (Placement(transformation(extent={{-100,96},{-80,116}}),
            iconTransformation(extent={{-100,96},{-80,116}})));
      Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor thermostat
        annotation (Placement(transformation(extent={{40,-10},{60,10}})));
      Modelica.Blocks.Interfaces.RealOutput zoneMeanAirTemperature
        "Zone mean air drybulb temperature"
        annotation (Placement(transformation(extent={{100,-10},{120,10}})));
      Modelica.Blocks.Sources.Constant convective(k=0)
        "Convective internal load"
        annotation (Placement(transformation(extent={{-100,10},{-80,30}})));
      Modelica.Blocks.Sources.Constant radiative(k=0) "Radiative internal load"
        annotation (Placement(transformation(extent={{-100,-20},{-80,0}})));
      Modelica.Blocks.Sources.Constant latent(k=0) "Latent internal load"
        annotation (Placement(transformation(extent={{-100,-50},{-80,-30}})));
      Modelica.Blocks.Routing.Multiplex3 multiplex3_1
        annotation (Placement(transformation(extent={{-60,-20},{-40,0}})));
      Buildings.HeatTransfer.Sources.FixedHeatFlow adiabaticFloor(Q_flow=0)
        annotation (Placement(transformation(extent={{-60,-62},{-40,-42}})));
    equation
      connect(zone.weaBus, weaBus) annotation (Line(
          points={{17.9,17.9},{17.9,60},{-90,60},{-90,106}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%second",
          index=1,
          extent={{6,3},{6,3}}));
      connect(zone.heaPorAir, thermostat.port)
        annotation (Line(points={{-1,0},{-1,0},{40,0}}, color={191,0,0}));
      connect(thermostat.T, zoneMeanAirTemperature)
        annotation (Line(points={{60,0},{110,0}}, color={0,0,127}));
      connect(radiative.y, multiplex3_1.u2[1])
        annotation (Line(points={{-79,-10},{-62,-10}}, color={0,0,127}));
      connect(convective.y, multiplex3_1.u1[1]) annotation (Line(points={{-79,
              20},{-74,20},{-74,-3},{-62,-3}}, color={0,0,127}));
      connect(latent.y, multiplex3_1.u3[1]) annotation (Line(points={{-79,-40},
              {-74,-40},{-74,-17},{-62,-17}}, color={0,0,127}));
      connect(multiplex3_1.y, zone.qGai_flow) annotation (Line(points={{-39,-10},
              {-34,-10},{-34,8},{-21.6,8}}, color={0,0,127}));
      connect(adiabaticFloor.port, zone.surf_conBou[1]) annotation (Line(points={{-40,
              -52},{-18,-52},{6,-52},{6,-16}}, color={191,0,0}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Rectangle(
              extent={{-100,-100},{100,100}},
              lineColor={95,95,95},
              fillColor={95,95,95},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-92,92},{92,-92}},
              pattern=LinePattern.None,
              lineColor={117,148,176},
              fillColor={170,213,255},
              fillPattern=FillPattern.Sphere)}),                     Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end SingleZoneFF;

    model SingleZoneUncontrolled_NoSunNoWind
      "Single zone thermal envelope model based on 1ZoneUncontrolled.idf EnergyPlus example file"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      parameter Modelica.SIunits.Angle lat "Building latitude";
      parameter
        SOEPDemo.Constructions.ASHRAE_189_1_2009_ExtWall_Mass_ClimateZone_5
        Wall001 "Exterior wall facing south";
      parameter
        SOEPDemo.Constructions.ASHRAE_189_1_2009_ExtWall_Mass_ClimateZone_5
        Wall002 "Exterior wall facing east";
      parameter
        SOEPDemo.Constructions.ASHRAE_189_1_2009_ExtWall_Mass_ClimateZone_5
        Wall003 "Exterior wall facing north";
      parameter
        SOEPDemo.Constructions.ASHRAE_189_1_2009_ExtWall_Mass_ClimateZone_5
        Wall004 "Exterior wall facing west";
      parameter SOEPDemo.Constructions.FLOOR Flr001 "Floor";
      parameter SOEPDemo.Constructions.ROOF31 Roof001 "Roof";
      Buildings.ThermalZones.Detailed.MixedAir zone(
        redeclare package Medium = MediumA,
        AFlo=15.24*15.24,
        hRoo=4.572,
        nConExt=1,
        datConExt(layers={Wall001},
               A={15.24*4.572},
               til={Buildings.Types.Tilt.Wall},
               azi={Buildings.Types.Azimuth.S}),
        nConExtWin=0,
        nConPar=0,
        nConBou=5,
        datConBou(layers={Flr001, Wall002, Wall003, Wall004, Roof001},
               A={15.24*15.24, 15.24*4.572, 15.24*4.572, 15.24*4.572, 15.24*15.24},
               til={Buildings.Types.Tilt.Floor, Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Ceiling}),
        nSurBou=0,
        linearizeRadiation = true,
        energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
        T_start = 273.15 + 6.407943101,
        intConMod=Buildings.HeatTransfer.Types.InteriorConvection.Temperature,
        extConMod=Buildings.HeatTransfer.Types.ExteriorConvection.TemperatureWind,
        lat(displayUnit="rad") = lat)
                              "Zone model"
        annotation (Placement(transformation(extent={{-20,-20},{20,20}})));

      Buildings.HeatTransfer.Sources.PrescribedHeatFlow adiabaticConPar
        annotation (Placement(transformation(extent={{-58,-80},{-38,-60}})));
      Modelica.Blocks.Sources.Constant adiabatic(k=0)
        annotation (Placement(transformation(extent={{-100,-80},{-80,-60}})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus "Weather data"
        annotation (Placement(transformation(extent={{-100,96},{-80,116}}),
            iconTransformation(extent={{-100,96},{-80,116}})));
      Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor thermostat
        annotation (Placement(transformation(extent={{40,-10},{60,10}})));
      Modelica.Blocks.Interfaces.RealOutput zoneMeanAirTemperature
        "Zone mean air drybulb temperature"
        annotation (Placement(transformation(extent={{100,-10},{120,10}})));
      Modelica.Blocks.Sources.Constant convective(k=0)
        "Convective internal load"
        annotation (Placement(transformation(extent={{-100,10},{-80,30}})));
      Modelica.Blocks.Sources.Constant radiative(k=0) "Radiative internal load"
        annotation (Placement(transformation(extent={{-100,-20},{-80,0}})));
      Modelica.Blocks.Sources.Constant latent(k=0) "Latent internal load"
        annotation (Placement(transformation(extent={{-100,-50},{-80,-30}})));
      Modelica.Blocks.Routing.Multiplex3 multiplex3_1
        annotation (Placement(transformation(extent={{-60,-20},{-40,0}})));
    equation
      connect(adiabatic.y, adiabaticConPar.Q_flow)
        annotation (Line(points={{-79,-70},{-60,-70},{-58,-70}}, color={0,0,127}));
      connect(zone.weaBus, weaBus) annotation (Line(
          points={{17.9,17.9},{17.9,60},{-90,60},{-90,106}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%second",
          index=1,
          extent={{6,3},{6,3}}));
      connect(zone.heaPorAir, thermostat.port)
        annotation (Line(points={{-1,0},{-1,0},{40,0}}, color={191,0,0}));
      connect(thermostat.T, zoneMeanAirTemperature)
        annotation (Line(points={{60,0},{110,0}}, color={0,0,127}));
      connect(radiative.y, multiplex3_1.u2[1])
        annotation (Line(points={{-79,-10},{-62,-10}}, color={0,0,127}));
      connect(convective.y, multiplex3_1.u1[1]) annotation (Line(points={{-79,
              20},{-74,20},{-74,-3},{-62,-3}}, color={0,0,127}));
      connect(latent.y, multiplex3_1.u3[1]) annotation (Line(points={{-79,-40},
              {-74,-40},{-74,-17},{-62,-17}}, color={0,0,127}));
      connect(multiplex3_1.y, zone.qGai_flow) annotation (Line(points={{-39,-10},
              {-34,-10},{-34,8},{-21.6,8}}, color={0,0,127}));
      connect(adiabaticConPar.port, zone.surf_conBou[1])
        annotation (Line(points={{-38,-70},{6,-70},{6,-16.8}},
                                                             color={191,0,0}));
      connect(adiabaticConPar.port, zone.surf_conBou[1])
        annotation (Line(points={{-38,-70},{6,-70},{6,-16.8}},
                                                             color={191,0,0}));
      connect(adiabaticConPar.port, zone.surf_conBou[1])
        annotation (Line(points={{-38,-70},{6,-70},{6,-16.8}},
                                                             color={191,0,0}));
      connect(adiabaticConPar.port, zone.surf_conBou[1]) annotation (Line(points={{-38,-70},
              {-16,-70},{6,-70},{6,-16.8}},    color={191,0,0}));
      connect(adiabaticConPar.port, zone.surf_conBou[1]) annotation (Line(points={{-38,-70},
              {-16,-70},{6,-70},{6,-16.8}},    color={191,0,0}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Rectangle(
              extent={{-100,-100},{100,100}},
              lineColor={95,95,95},
              fillColor={95,95,95},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-92,92},{92,-92}},
              pattern=LinePattern.None,
              lineColor={117,148,176},
              fillColor={170,213,255},
              fillPattern=FillPattern.Sphere)}),                     Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end SingleZoneUncontrolled_NoSunNoWind;

    model SingleZoneUncontrolled_NoSunNoWind_ConstExtConvCoeff
      "Single zone thermal envelope model based on 1ZoneUncontrolled.idf EnergyPlus example file"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      parameter Modelica.SIunits.Angle lat "Building latitude";
      parameter
        SOEPDemo.Constructions.ASHRAE_189_1_2009_ExtWall_Mass_ClimateZone_5
        Wall001 "Exterior wall facing south";
      parameter
        SOEPDemo.Constructions.ASHRAE_189_1_2009_ExtWall_Mass_ClimateZone_5
        Wall002 "Exterior wall facing east";
      parameter
        SOEPDemo.Constructions.ASHRAE_189_1_2009_ExtWall_Mass_ClimateZone_5
        Wall003 "Exterior wall facing north";
      parameter
        SOEPDemo.Constructions.ASHRAE_189_1_2009_ExtWall_Mass_ClimateZone_5
        Wall004 "Exterior wall facing west";
      parameter SOEPDemo.Constructions.FLOOR Flr001 "Floor";
      parameter SOEPDemo.Constructions.ROOF31 Roof001 "Roof";
      Buildings.ThermalZones.Detailed.MixedAir zone(
        redeclare package Medium = MediumA,
        AFlo=15.24*15.24,
        hRoo=4.572,
        nConExt=1,
        datConExt(layers={Wall001},
               A={15.24*4.572},
               til={Buildings.Types.Tilt.Wall},
               azi={Buildings.Types.Azimuth.S}),
        nConExtWin=0,
        nConPar=0,
        nConBou=5,
        datConBou(layers={Flr001, Wall002, Wall003, Wall004, Roof001},
               A={15.24*15.24, 15.24*4.572, 15.24*4.572, 15.24*4.572, 15.24*15.24},
               til={Buildings.Types.Tilt.Floor, Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Ceiling}),
        nSurBou=0,
        linearizeRadiation = true,
        energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
        T_start = 273.15 + 5.548013437,
        intConMod=Buildings.HeatTransfer.Types.InteriorConvection.Temperature,
        lat(displayUnit="rad") = lat,
        extConMod=Buildings.HeatTransfer.Types.ExteriorConvection.Fixed,
        hExtFixed=10.79)      "Zone model"
        annotation (Placement(transformation(extent={{-20,-20},{20,20}})));

      Buildings.HeatTransfer.Sources.PrescribedHeatFlow adiabaticConPar
        annotation (Placement(transformation(extent={{-58,-80},{-38,-60}})));
      Modelica.Blocks.Sources.Constant adiabatic(k=0)
        annotation (Placement(transformation(extent={{-100,-80},{-80,-60}})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus "Weather data"
        annotation (Placement(transformation(extent={{-100,96},{-80,116}}),
            iconTransformation(extent={{-100,96},{-80,116}})));
      Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor thermostat
        annotation (Placement(transformation(extent={{40,-10},{60,10}})));
      Modelica.Blocks.Interfaces.RealOutput zoneMeanAirTemperature
        "Zone mean air drybulb temperature"
        annotation (Placement(transformation(extent={{100,-10},{120,10}})));
      Modelica.Blocks.Sources.Constant convective(k=0)
        "Convective internal load"
        annotation (Placement(transformation(extent={{-100,10},{-80,30}})));
      Modelica.Blocks.Sources.Constant radiative(k=0) "Radiative internal load"
        annotation (Placement(transformation(extent={{-100,-20},{-80,0}})));
      Modelica.Blocks.Sources.Constant latent(k=0) "Latent internal load"
        annotation (Placement(transformation(extent={{-100,-50},{-80,-30}})));
      Modelica.Blocks.Routing.Multiplex3 multiplex3_1
        annotation (Placement(transformation(extent={{-60,-20},{-40,0}})));
    equation
      connect(adiabatic.y, adiabaticConPar.Q_flow)
        annotation (Line(points={{-79,-70},{-60,-70},{-58,-70}}, color={0,0,127}));
      connect(zone.weaBus, weaBus) annotation (Line(
          points={{17.9,17.9},{17.9,60},{-90,60},{-90,106}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%second",
          index=1,
          extent={{6,3},{6,3}}));
      connect(zone.heaPorAir, thermostat.port)
        annotation (Line(points={{-1,0},{-1,0},{40,0}}, color={191,0,0}));
      connect(thermostat.T, zoneMeanAirTemperature)
        annotation (Line(points={{60,0},{110,0}}, color={0,0,127}));
      connect(radiative.y, multiplex3_1.u2[1])
        annotation (Line(points={{-79,-10},{-62,-10}}, color={0,0,127}));
      connect(convective.y, multiplex3_1.u1[1]) annotation (Line(points={{-79,
              20},{-74,20},{-74,-3},{-62,-3}}, color={0,0,127}));
      connect(latent.y, multiplex3_1.u3[1]) annotation (Line(points={{-79,-40},
              {-74,-40},{-74,-17},{-62,-17}}, color={0,0,127}));
      connect(multiplex3_1.y, zone.qGai_flow) annotation (Line(points={{-39,-10},
              {-34,-10},{-34,8},{-21.6,8}}, color={0,0,127}));
      connect(adiabaticConPar.port, zone.surf_conBou[1])
        annotation (Line(points={{-38,-70},{6,-70},{6,-16.8}},
                                                             color={191,0,0}));
      connect(adiabaticConPar.port, zone.surf_conBou[1])
        annotation (Line(points={{-38,-70},{6,-70},{6,-16.8}},
                                                             color={191,0,0}));
      connect(adiabaticConPar.port, zone.surf_conBou[1])
        annotation (Line(points={{-38,-70},{6,-70},{6,-16.8}},
                                                             color={191,0,0}));
      connect(adiabaticConPar.port, zone.surf_conBou[1]) annotation (Line(points={{-38,-70},
              {-16,-70},{6,-70},{6,-16.8}},    color={191,0,0}));
      connect(adiabaticConPar.port, zone.surf_conBou[1]) annotation (Line(points={{-38,-70},
              {-16,-70},{6,-70},{6,-16.8}},    color={191,0,0}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Rectangle(
              extent={{-100,-100},{100,100}},
              lineColor={95,95,95},
              fillColor={95,95,95},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-92,92},{92,-92}},
              pattern=LinePattern.None,
              lineColor={117,148,176},
              fillColor={170,213,255},
              fillPattern=FillPattern.Sphere)}),                     Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end SingleZoneUncontrolled_NoSunNoWind_ConstExtConvCoeff;

    model SingleZoneUncontrolled_NoWind
      "Single zone thermal envelope model based on 1ZoneUncontrolled.idf EnergyPlus example file"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      parameter Modelica.SIunits.Angle lat "Building latitude";
      parameter
        SOEPDemo.Constructions.ASHRAE_189_1_2009_ExtWall_Mass_ClimateZone_5
        Wall001 "Exterior wall facing south";
      parameter
        SOEPDemo.Constructions.ASHRAE_189_1_2009_ExtWall_Mass_ClimateZone_5
        Wall002 "Exterior wall facing east";
      parameter
        SOEPDemo.Constructions.ASHRAE_189_1_2009_ExtWall_Mass_ClimateZone_5
        Wall003 "Exterior wall facing north";
      parameter
        SOEPDemo.Constructions.ASHRAE_189_1_2009_ExtWall_Mass_ClimateZone_5
        Wall004 "Exterior wall facing west";
      parameter SOEPDemo.Constructions.FLOOR Flr001 "Floor";
      parameter SOEPDemo.Constructions.ROOF31 Roof001 "Roof";
      Buildings.ThermalZones.Detailed.MixedAir zone(
        redeclare package Medium = MediumA,
        AFlo=15.24*15.24,
        hRoo=4.572,
        nConExt=5,
        datConExt(layers={Wall001, Wall002, Wall003, Wall004, Roof001},
               A={15.24*4.572, 15.24*4.572, 15.24*4.572, 15.24*4.572, 15.24*15.24},
               til={Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Wall, Buildings.Types.Tilt.Ceiling},
               azi={Buildings.Types.Azimuth.S, Buildings.Types.Azimuth.E, Buildings.Types.Azimuth.N, Buildings.Types.Azimuth.W, Buildings.Types.Azimuth.S}),
        nConExtWin=0,
        nConPar=0,
        nConBou=1,
        datConBou(layers={Flr001},
               A={15.24*15.24},
               til={Buildings.Types.Tilt.Floor}),
        nSurBou=0,
        linearizeRadiation = true,
        energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
        T_start = 273.15 - 0.656203558,
        intConMod=Buildings.HeatTransfer.Types.InteriorConvection.Temperature,
        extConMod=Buildings.HeatTransfer.Types.ExteriorConvection.TemperatureWind,
        lat(displayUnit="rad") = lat)
                              "Zone model"
        annotation (Placement(transformation(extent={{-20,-20},{20,20}})));

      Buildings.HeatTransfer.Sources.PrescribedHeatFlow adiabaticFloor
        annotation (Placement(transformation(extent={{-60,-80},{-40,-60}})));
      Modelica.Blocks.Sources.Constant adiabatic(k=0)
        annotation (Placement(transformation(extent={{-100,-80},{-80,-60}})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus "Weather data"
        annotation (Placement(transformation(extent={{-100,96},{-80,116}}),
            iconTransformation(extent={{-100,96},{-80,116}})));
      Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor thermostat
        annotation (Placement(transformation(extent={{40,-10},{60,10}})));
      Modelica.Blocks.Interfaces.RealOutput zoneMeanAirTemperature
        "Zone mean air drybulb temperature"
        annotation (Placement(transformation(extent={{100,-10},{120,10}})));
      Modelica.Blocks.Sources.Constant convective(k=0)
        "Convective internal load"
        annotation (Placement(transformation(extent={{-100,10},{-80,30}})));
      Modelica.Blocks.Sources.Constant radiative(k=0) "Radiative internal load"
        annotation (Placement(transformation(extent={{-100,-20},{-80,0}})));
      Modelica.Blocks.Sources.Constant latent(k=0) "Latent internal load"
        annotation (Placement(transformation(extent={{-100,-50},{-80,-30}})));
      Modelica.Blocks.Routing.Multiplex3 multiplex3_1
        annotation (Placement(transformation(extent={{-60,-20},{-40,0}})));
    equation
      connect(adiabaticFloor.port, zone.surf_conBou[1]) annotation (Line(points={{-40,-70},
              {-40,-70},{6,-70},{6,-16}},      color={191,0,0}));
      connect(adiabatic.y, adiabaticFloor.Q_flow)
        annotation (Line(points={{-79,-70},{-70,-70},{-60,-70}}, color={0,0,127}));
      connect(zone.weaBus, weaBus) annotation (Line(
          points={{17.9,17.9},{17.9,60},{-90,60},{-90,106}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%second",
          index=1,
          extent={{6,3},{6,3}}));
      connect(zone.heaPorAir, thermostat.port)
        annotation (Line(points={{-1,0},{-1,0},{40,0}}, color={191,0,0}));
      connect(thermostat.T, zoneMeanAirTemperature)
        annotation (Line(points={{60,0},{110,0}}, color={0,0,127}));
      connect(radiative.y, multiplex3_1.u2[1])
        annotation (Line(points={{-79,-10},{-62,-10}}, color={0,0,127}));
      connect(convective.y, multiplex3_1.u1[1]) annotation (Line(points={{-79,
              20},{-74,20},{-74,-3},{-62,-3}}, color={0,0,127}));
      connect(latent.y, multiplex3_1.u3[1]) annotation (Line(points={{-79,-40},
              {-74,-40},{-74,-17},{-62,-17}}, color={0,0,127}));
      connect(multiplex3_1.y, zone.qGai_flow) annotation (Line(points={{-39,-10},
              {-34,-10},{-34,8},{-21.6,8}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Rectangle(
              extent={{-100,-100},{100,100}},
              lineColor={95,95,95},
              fillColor={95,95,95},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-92,92},{92,-92}},
              pattern=LinePattern.None,
              lineColor={117,148,176},
              fillColor={170,213,255},
              fillPattern=FillPattern.Sphere)}),                     Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end SingleZoneUncontrolled_NoWind;

    model SingleZoneAirHVAC
      "Extends SingleZoneFF with supply and return air ports and measurements."
      extends SingleZoneFF(zone(
                           nPorts=2));
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      Schedules.coolingSetpointSchedule coolingSetpointSchedule(smoothness=
            Modelica.Blocks.Types.Smoothness.LinearSegments)
        annotation (Placement(transformation(extent={{30,-90},{50,-70}})));
      Schedules.heatingSetpointSchedule heatingSetpointSchedule(smoothness=
            Modelica.Blocks.Types.Smoothness.LinearSegments)
        annotation (Placement(transformation(extent={{30,-62},{50,-42}})));
      Modelica.Blocks.Interfaces.RealOutput TheatSetpoint "Heating setpoint"
        annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
      Modelica.Blocks.Interfaces.RealOutput TcoolSetpoint "Cooling setpoint"
        annotation (Placement(transformation(extent={{100,-90},{120,-70}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          returnAirTemp(redeclare package Medium =
                   MediumA, m_flow_nominal=designAirFlow)
        annotation (Placement(transformation(extent={{28,88},{48,108}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          supplyAirTemp(redeclare package Medium =
                   MediumA, m_flow_nominal=designAirFlow)
        annotation (Placement(transformation(extent={{-42,88},{-22,108}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_a supplyAir(
          redeclare package Medium = MediumA) "HVAC supply air port"
        annotation (Placement(transformation(extent={{-66,58},{-46,138}}),
            iconTransformation(extent={{-60,100},{-24,114}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b returnAir(
          redeclare package Medium = MediumA) "HVAC return air port"
        annotation (Placement(transformation(extent={{0,58},{20,138}}),
            iconTransformation(extent={{28,100},{64,114}})));
      Buildings.Fluid.Sensors.MassFlowRate supplyAirFlow(redeclare package Medium =
                   MediumA) "Heating supply air flowrate"
        annotation (Placement(transformation(extent={{-54,34},{-42,46}})));
      Buildings.Fluid.Sensors.MassFlowRate returnAirFlow(redeclare package Medium =
                   MediumA)                              "Return air flowrate"
        annotation (Placement(transformation(extent={{-6,34},{6,46}})));
      Modelica.Blocks.Interfaces.RealOutput hvacHeatPower "HVAC heating power"
        annotation (Placement(transformation(extent={{100,70},{120,90}})));
      Modelica.Blocks.Sources.RealExpression heatingPowerCalc(y=supplyAirFlow.m_flow
            *1008*1.2*(supplyAirTemp.T - zoneMeanAirTemperature))
        annotation (Placement(transformation(extent={{70,70},{90,90}})));
      Modelica.Blocks.Continuous.FirstOrder firstOrder(
        y_start=0,
        initType=Modelica.Blocks.Types.Init.SteadyState,
        T=30) annotation (Placement(transformation(extent={{66,-62},{86,-42}})));
      Modelica.Blocks.Continuous.FirstOrder firstOrder1(
        y_start=0,
        initType=Modelica.Blocks.Types.Init.SteadyState,
        T=30) annotation (Placement(transformation(extent={{66,-90},{86,-70}})));
    equation
      connect(returnAir,returnAir)
        annotation (Line(points={{10,98},{10,98}}, color={0,127,255}));
      connect(supplyAir,supplyAirTemp. port_a)
        annotation (Line(points={{-56,98},{-50,98},{-42,98}}, color={0,127,255}));
      connect(supplyAirTemp.port_b,supplyAirFlow. port_a) annotation (Line(points={{-22,98},
              {-10,98},{-10,68},{-60,68},{-60,40},{-54,40}},         color={0,127,255}));
      connect(returnAirTemp.port_a,returnAir)
        annotation (Line(points={{28,98},{10,98}}, color={0,127,255}));
      connect(returnAirTemp.port_b,returnAirFlow. port_b) annotation (Line(points={{48,98},
              {56,98},{56,40},{6,40}},        color={0,127,255}));
      connect(heatingPowerCalc.y,hvacHeatPower)
        annotation (Line(points={{91,80},{110,80}}, color={0,0,127}));
      connect(supplyAirFlow.port_b, zone.ports[1]) annotation (Line(points={{-42,40},
              {-30,40},{-30,-10},{-15,-10}}, color={0,127,255}));
      connect(returnAirFlow.port_a, zone.ports[2]) annotation (Line(points={{-6,40},
              {-26,40},{-26,-10},{-15,-10}}, color={0,127,255}));
      connect(heatingSetpointSchedule.y[1], firstOrder.u)
        annotation (Line(points={{51,-52},{64,-52}}, color={0,0,127}));
      connect(firstOrder.y, TheatSetpoint) annotation (Line(points={{87,-52},{
              94,-52},{94,-60},{110,-60}}, color={0,0,127}));
      connect(coolingSetpointSchedule.y[1], firstOrder1.u) annotation (Line(
            points={{51,-80},{58,-80},{64,-80}}, color={0,0,127}));
      connect(firstOrder1.y, TcoolSetpoint)
        annotation (Line(points={{87,-80},{110,-80}}, color={0,0,127}));
    end SingleZoneAirHVAC;

    model SingleZoneIdealAirHVAC
      extends SingleZoneFF(zone(nPorts = 3));
      Modelica.Blocks.Sources.RealExpression heatingPowerCalc(y=supplyAirFlowHeat.m_flow
            *1008*1.2*(40 + 273.15 - zoneMeanAirTemperature))
        annotation (Placement(transformation(extent={{38,70},{58,90}})));
      Modelica.Blocks.Sources.RealExpression coolingPowerCalc(y=supplyAirFlowCool.m_flow
            *1008*1.2*(zoneMeanAirTemperature - 14 - 273.15))
        annotation (Placement(transformation(extent={{38,50},{58,70}})));
      Modelica.Blocks.Interfaces.RealOutput heatingPower "HVAC heating power"
        annotation (Placement(transformation(extent={{100,70},{120,90}})));
      Modelica.Blocks.Interfaces.RealOutput coolingPower "HVAC cooling power"
        annotation (Placement(transformation(extent={{100,50},{120,70}})));
      Schedules.coolingSetpointSchedule coolingSetpointSchedule
        annotation (Placement(transformation(extent={{30,-90},{50,-70}})));
      Schedules.heatingSetpointSchedule heatingSetpointSchedule
        annotation (Placement(transformation(extent={{30,-62},{50,-42}})));
      Modelica.Blocks.Interfaces.RealOutput TheatSetpoint "Heating setpoint"
        annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
      Modelica.Blocks.Interfaces.RealOutput TcoolSetpoint "Cooling setpoint"
        annotation (Placement(transformation(extent={{100,-90},{120,-70}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b supplyAirHeat(
          redeclare package Medium = MediumA) "Heating supply air" annotation (
          Placement(transformation(extent={{-62,56},{-42,136}}), iconTransformation(
              extent={{-60,100},{-24,114}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b supplyAirCool(
          redeclare package Medium = MediumA) "Cooling supply air" annotation (
          Placement(transformation(extent={{-26,56},{-6,136}}),  iconTransformation(
              extent={{-18,100},{18,114}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b Return(redeclare
          package Medium = MediumA) "Return air" annotation (Placement(
            transformation(extent={{10,56},{30,136}}),iconTransformation(extent={{64,100},
                {100,114}})));
      Buildings.Fluid.Sensors.MassFlowRate returnAirFlow(redeclare package Medium =
                   MediumA)                              "Return air flowrate"
        annotation (Placement(transformation(extent={{-2,32},{10,44}})));
      Buildings.Fluid.Sensors.MassFlowRate supplyAirFlowCool(redeclare package
          Medium = MediumA)
        "Cooling supply air flowrate"
        annotation (Placement(transformation(extent={{-28,32},{-16,44}})));
      Buildings.Fluid.Sensors.MassFlowRate supplyAirFlowHeat(redeclare package
          Medium = MediumA) "Heating supply air flowrate"
        annotation (Placement(transformation(extent={{-50,32},{-38,44}})));
    equation
      connect(heatingPowerCalc.y,heatingPower)
        annotation (Line(points={{59,80},{110,80}}, color={0,0,127}));
      connect(coolingPowerCalc.y,coolingPower)
        annotation (Line(points={{59,60},{110,60}}, color={0,0,127}));
      connect(TheatSetpoint,heatingSetpointSchedule. y[1]) annotation (Line(points={{110,-60},
              {70,-60},{70,-52},{51,-52}},           color={0,0,127}));
      connect(TcoolSetpoint,coolingSetpointSchedule. y[1])
        annotation (Line(points={{110,-80},{51,-80}},          color={0,0,127}));
      connect(supplyAirHeat,supplyAirFlowHeat. port_a)
        annotation (Line(points={{-52,96},{-52,38},{-50,38}}, color={0,127,255}));
      connect(supplyAirCool,supplyAirFlowCool. port_b)
        annotation (Line(points={{-16,96},{-16,96},{-16,38}}, color={0,127,255}));
      connect(Return,returnAirFlow. port_b)
        annotation (Line(points={{20,96},{20,38},{10,38}},color={0,127,255}));
      connect(returnAirFlow.port_a, zone.ports[3]) annotation (Line(points={{-2,38},
              {-10,38},{-10,20},{-26,20},{-26,-10},{-15,-10}},           color={0,127,
              255}));
      connect(supplyAirFlowCool.port_a, zone.ports[2]) annotation (Line(points={{-28,38},
              {-28,-10},{-15,-10}},     color={0,127,255}));
      connect(supplyAirFlowHeat.port_b, zone.ports[1]) annotation (Line(points={{-38,38},
              {-32,38},{-32,-10},{-15,-10}},               color={0,127,255}));
    end SingleZoneIdealAirHVAC;

    model SingleZoneAirHVAC_NoFirstOrder
      "Extends SingleZoneFF with supply and return air ports and measurements."
      extends SingleZoneFF(zone(
                           nPorts=2));
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      Schedules.coolingSetpointSchedule coolingSetpointSchedule(smoothness=
            Modelica.Blocks.Types.Smoothness.LinearSegments)
        annotation (Placement(transformation(extent={{30,-90},{50,-70}})));
      Schedules.heatingSetpointSchedule heatingSetpointSchedule(smoothness=
            Modelica.Blocks.Types.Smoothness.LinearSegments)
        annotation (Placement(transformation(extent={{30,-62},{50,-42}})));
      Modelica.Blocks.Interfaces.RealOutput TheatSetpoint "Heating setpoint"
        annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
      Modelica.Blocks.Interfaces.RealOutput TcoolSetpoint "Cooling setpoint"
        annotation (Placement(transformation(extent={{100,-90},{120,-70}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          returnAirTemp(redeclare package
          Medium = MediumA, m_flow_nominal=designAirFlow)
        annotation (Placement(transformation(extent={{28,88},{48,108}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          supplyAirTemp(redeclare package
          Medium = MediumA, m_flow_nominal=designAirFlow)
        annotation (Placement(transformation(extent={{-42,88},{-22,108}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_a supplyAir(
          redeclare package Medium = MediumA) "HVAC supply air port"
        annotation (Placement(transformation(extent={{-66,58},{-46,138}}),
            iconTransformation(extent={{-60,100},{-24,114}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b returnAir(
          redeclare package Medium = MediumA) "HVAC return air port"
        annotation (Placement(transformation(extent={{0,58},{20,138}}),
            iconTransformation(extent={{28,100},{64,114}})));
      Buildings.Fluid.Sensors.MassFlowRate supplyAirFlow(redeclare package
          Medium = MediumA) "Heating supply air flowrate"
        annotation (Placement(transformation(extent={{-54,34},{-42,46}})));
      Buildings.Fluid.Sensors.MassFlowRate returnAirFlow(redeclare package
          Medium = MediumA)                              "Return air flowrate"
        annotation (Placement(transformation(extent={{-6,34},{6,46}})));
      Modelica.Blocks.Interfaces.RealOutput hvacHeatPower "HVAC heating power"
        annotation (Placement(transformation(extent={{100,70},{120,90}})));
      Modelica.Blocks.Sources.RealExpression heatingPowerCalc(y=supplyAirFlow.m_flow
            *1008*1.2*(supplyAirTemp.T - zoneMeanAirTemperature))
        annotation (Placement(transformation(extent={{70,70},{90,90}})));
    equation
      connect(returnAir,returnAir)
        annotation (Line(points={{10,98},{10,98}}, color={0,127,255}));
      connect(supplyAir,supplyAirTemp. port_a)
        annotation (Line(points={{-56,98},{-50,98},{-42,98}}, color={0,127,255}));
      connect(supplyAirTemp.port_b,supplyAirFlow. port_a) annotation (Line(points={{-22,98},
              {-10,98},{-10,68},{-60,68},{-60,40},{-54,40}},         color={0,127,255}));
      connect(returnAirTemp.port_a,returnAir)
        annotation (Line(points={{28,98},{10,98}}, color={0,127,255}));
      connect(returnAirTemp.port_b,returnAirFlow. port_b) annotation (Line(points={{48,98},
              {56,98},{56,40},{6,40}},        color={0,127,255}));
      connect(heatingPowerCalc.y,hvacHeatPower)
        annotation (Line(points={{91,80},{110,80}}, color={0,0,127}));
      connect(supplyAirFlow.port_b, zone.ports[1]) annotation (Line(points={{-42,40},
              {-30,40},{-30,-10},{-15,-10}}, color={0,127,255}));
      connect(returnAirFlow.port_a, zone.ports[2]) annotation (Line(points={{-6,40},
              {-26,40},{-26,-10},{-15,-10}}, color={0,127,255}));
      connect(heatingSetpointSchedule.y[1], TheatSetpoint) annotation (Line(
            points={{51,-52},{78,-52},{78,-60},{110,-60}}, color={0,0,127}));
      connect(coolingSetpointSchedule.y[1], TcoolSetpoint) annotation (Line(
            points={{51,-80},{110,-80},{110,-80}}, color={0,0,127}));
    end SingleZoneAirHVAC_NoFirstOrder;

    model Case600FF
      "Basic test with light-weight construction and free floating temperature"
      package MediumA = Buildings.Media.Air "Medium model";
      parameter Modelica.SIunits.Angle lat "Building latitude";
      parameter Modelica.SIunits.Angle S_=
        Buildings.Types.Azimuth.S "Azimuth for south walls";
      parameter Modelica.SIunits.Angle E_=
        Buildings.Types.Azimuth.E "Azimuth for east walls";
      parameter Modelica.SIunits.Angle W_=
        Buildings.Types.Azimuth.W "Azimuth for west walls";
      parameter Modelica.SIunits.Angle N_=
        Buildings.Types.Azimuth.N "Azimuth for north walls";
      parameter Modelica.SIunits.Angle C_=
        Buildings.Types.Tilt.Ceiling "Tilt for ceiling";
      parameter Modelica.SIunits.Angle F_=
        Buildings.Types.Tilt.Floor "Tilt for floor";
      parameter Modelica.SIunits.Angle Z_=
        Buildings.Types.Tilt.Wall "Tilt for wall";
      parameter Integer nConExtWin = 1 "Number of constructions with a window";
      parameter Integer nConBou = 1
        "Number of surface that are connected to constructions that are modeled inside the room";
      parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic matExtWal(
        nLay=3,
        absIR_a=0.9,
        absIR_b=0.9,
        absSol_a=0.6,
        absSol_b=0.6,
        material={Buildings.HeatTransfer.Data.Solids.Generic(
            x=0.009,
            k=0.140,
            c=0,
            d=0,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef),
                             Buildings.HeatTransfer.Data.Solids.Generic(
            x=0.066,
            k=0.040,
            c=840,
            d=12,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef),
                             Buildings.HeatTransfer.Data.Solids.Generic(
            x=0.012,
            k=0.160,
            c=840,
            d=950,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef)})
                               "Exterior wall"
        annotation (Placement(transformation(extent={{20,84},{34,98}})));
      parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic
                                                              matFlo(final nLay=
               2,
        absIR_a=0.9,
        absIR_b=0.9,
        absSol_a=0.6,
        absSol_b=0.6,
        material={Buildings.HeatTransfer.Data.Solids.Generic(
            x=1.003,
            k=0.040,
            c=0,
            d=0,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef),
                             Buildings.HeatTransfer.Data.Solids.Generic(
            x=0.025,
            k=0.140,
            c=1200,
            d=650,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef)})
                               "Floor"
        annotation (Placement(transformation(extent={{80,84},{94,98}})));
       parameter Buildings.HeatTransfer.Data.Solids.Generic soil(
        x=2,
        k=1.3,
        c=800,
        d=1500) "Soil properties"
        annotation (Placement(transformation(extent={{40,40},{60,60}})));

      Buildings.ThermalZones.Detailed.MixedAir roo(
        redeclare package Medium = MediumA,
        hRoo=2.7,
        nConExtWin=nConExtWin,
        nConBou=1,
        nPorts=3,
        energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
        AFlo=48,
        datConBou(
          layers={matFlo},
          each A=48,
          each til=F_),
        datConExt(
          layers={roof,matExtWal,matExtWal,matExtWal},
          A={48,6*2.7,6*2.7,8*2.7},
          til={C_,Z_,Z_,Z_},
          azi={S_,W_,E_,N_}),
        nConExt=4,
        nConPar=0,
        nSurBou=0,
        datConExtWin(
          layers={matExtWal},
          A={8*2.7},
          glaSys={window600},
          wWin={2*3},
          hWin={2},
          fFra={0.001},
          til={Z_},
          azi={S_}),
        massDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
        lat=lat,
        intConMod=Buildings.HeatTransfer.Types.InteriorConvection.Temperature,
        extConMod=Buildings.HeatTransfer.Types.ExteriorConvection.TemperatureWind)
        "Room model for Case 600"
        annotation (Placement(transformation(extent={{12,-30},{42,0}})));
      Modelica.Blocks.Sources.Constant qConGai_flow(k=80/48) "Convective heat gain"
        annotation (Placement(transformation(extent={{-78,-6},{-70,2}})));
      Modelica.Blocks.Sources.Constant qRadGai_flow(k=120/48) "Radiative heat gain"
        annotation (Placement(transformation(extent={{-66,2},{-58,10}})));
      Modelica.Blocks.Routing.Multiplex3 multiplex3_1
        annotation (Placement(transformation(extent={{-40,-6},{-32,2}})));
      Modelica.Blocks.Sources.Constant qLatGai_flow(k=0) "Latent heat gain"
        annotation (Placement(transformation(extent={{-66,-14},{-58,-6}})));
      Modelica.Blocks.Sources.Constant uSha(k=0)
        "Control signal for the shading device"
        annotation (Placement(transformation(extent={{-50,6},{-42,14}})));
      Modelica.Blocks.Routing.Replicator replicator(nout=max(1,nConExtWin))
        annotation (Placement(transformation(extent={{-34,6},{-26,14}})));
      Modelica.Thermal.HeatTransfer.Sources.FixedTemperature TSoi[nConBou](each T=
            283.15) "Boundary condition for construction"
                                              annotation (Placement(transformation(
            extent={{0,0},{-8,8}},
            origin={48,-52})));
      parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic roof(nLay=3,
        absIR_a=0.9,
        absIR_b=0.9,
        absSol_a=0.6,
        absSol_b=0.6,
        material={Buildings.HeatTransfer.Data.Solids.Generic(
            x=0.019,
            k=0.140,
            c=900,
            d=530,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef),
                             Buildings.HeatTransfer.Data.Solids.Generic(
            x=0.1118,
            k=0.040,
            c=840,
            d=12,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef),
                             Buildings.HeatTransfer.Data.Solids.Generic(
            x=0.010,
            k=0.160,
            c=840,
            d=950,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef)})
                               "Roof"
        annotation (Placement(transformation(extent={{60,84},{74,98}})));
      Buildings.ThermalZones.Detailed.Validation.BESTEST.Data.Win600
             window600(
        UFra=3,
        haveExteriorShade=false,
        haveInteriorShade=false) "Window"
        annotation (Placement(transformation(extent={{40,84},{54,98}})));
      Buildings.HeatTransfer.Conduction.SingleLayer soi(
        A=48,
        material=soil,
        steadyStateInitial=true,
        stateAtSurface_a=false,
        stateAtSurface_b=true,
        T_a_start=283.15,
        T_b_start=283.75) "2m deep soil (per definition on p.4 of ASHRAE 140-2007)"
        annotation (Placement(transformation(
            extent={{5,-5},{-3,3}},
            rotation=-90,
            origin={33,-35})));
      Buildings.Fluid.Sources.Outside sinInf(redeclare package Medium = MediumA,
          nPorts=1) "Sink model for air infiltration"
               annotation (Placement(transformation(extent={{-24,-26},{-12,-14}})));
      Modelica.Blocks.Sources.Constant InfiltrationRate(k=48*2.7*0.5/3600)
        "0.41 ACH adjusted for the altitude (0.5 at sea level)"
        annotation (Placement(transformation(extent={{-96,-78},{-88,-70}})));
      Modelica.Blocks.Math.Product product
        annotation (Placement(transformation(extent={{-50,-60},{-40,-50}})));
      Buildings.Fluid.Sensors.Density density(redeclare package Medium = MediumA)
        "Air density inside the building"
        annotation (Placement(transformation(extent={{-40,-76},{-50,-66}})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus
        annotation (Placement(transformation(extent={{-98,96},{-82,112}})));
      replaceable parameter
        Buildings.ThermalZones.Detailed.Validation.BESTEST.Data.StandardResultsFreeFloating
          staRes(
            minT( Min=-18.8+273.15, Max=-15.6+273.15, Mean=-17.6+273.15),
            maxT( Min=64.9+273.15,  Max=69.5+273.15,  Mean=66.2+273.15),
            meanT(Min=24.2+273.15,  Max=25.9+273.15,  Mean=25.1+273.15))
              constrainedby Modelica.Icons.Record
        "Reference results from ASHRAE/ANSI Standard 140"
        annotation (Placement(transformation(extent={{80,40},{94,54}})));
      Modelica.Blocks.Math.MultiSum multiSum(nu=1)
        annotation (Placement(transformation(extent={{-78,-80},{-66,-68}})));

      Modelica.Blocks.Interfaces.RealOutput zoneMeanAirTemperature
        "Zone mean air drybulb temperature"
        annotation (Placement(transformation(extent={{100,-10},{120,10}})));
      Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor thermostat
        annotation (Placement(transformation(extent={{50,-26},{70,-6}})));
      Buildings.Fluid.Sources.Outside souInf(redeclare package Medium = MediumA,
          nPorts=1) "Source model for air infiltration"
        annotation (Placement(transformation(extent={{-64,-40},{-52,-28}})));
      Buildings.Fluid.Movers.FlowControlled_m_flow infMover(
        redeclare package Medium = MediumA,
        m_flow_nominal=0.02,
        addPowerToMedium=false,
        dp_nominal=0,
        tau=1,
        energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial)
                      "Prescribed infiltration mover"
        annotation (Placement(transformation(extent={{-36,-40},{-26,-30}})));
    equation
      connect(qRadGai_flow.y,multiplex3_1. u1[1])  annotation (Line(
          points={{-57.6,6},{-56,6},{-56,0.8},{-40.8,0.8}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(qLatGai_flow.y,multiplex3_1. u3[1])  annotation (Line(
          points={{-57.6,-10},{-50,-10},{-50,-4.8},{-40.8,-4.8}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(multiplex3_1.y, roo.qGai_flow) annotation (Line(
          points={{-31.6,-2},{-22,-2},{-22,-9},{10.8,-9}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(roo.uSha, replicator.y) annotation (Line(
          points={{10.8,-1.5},{-18,-1.5},{-18,10},{-25.6,10}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(qConGai_flow.y, multiplex3_1.u2[1]) annotation (Line(
          points={{-69.6,-2},{-40.8,-2}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(uSha.y, replicator.u) annotation (Line(
          points={{-41.6,10},{-34.8,10}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(density.port, roo.ports[1])  annotation (Line(
          points={{-45,-76},{2,-76},{2,-24.5},{15.75,-24.5}},
          color={0,127,255},
          smooth=Smooth.None));
      connect(density.d, product.u2) annotation (Line(
          points={{-50.5,-71},{-56,-71},{-56,-58},{-51,-58}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(TSoi[1].port, soi.port_a) annotation (Line(
          points={{40,-48},{32,-48},{32,-40}},
          color={191,0,0},
          smooth=Smooth.None));
      connect(soi.port_b, roo.surf_conBou[1]) annotation (Line(
          points={{32,-32},{32,-27},{31.5,-27}},
          color={191,0,0},
          smooth=Smooth.None));
      connect(multiSum.y, product.u1) annotation (Line(
          points={{-64.98,-74},{-54,-74},{-54,-52},{-51,-52}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(InfiltrationRate.y, multiSum.u[1]) annotation (Line(
          points={{-87.6,-74},{-78,-74}},
          color={0,0,127},
          smooth=Smooth.None));

      connect(sinInf.ports[1], roo.ports[2]) annotation (Line(points={{-12,-20},{14,
              -20},{14,-22.5},{15.75,-22.5}}, color={0,127,255}));
      connect(weaBus,sinInf. weaBus) annotation (Line(
          points={{-90,104},{-90,104},{-90,-20},{-24,-20},{-24,-19.88}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));
      connect(weaBus, roo.weaBus) annotation (Line(
          points={{-90,104},{-90,104},{-90,20},{40,20},{40,-2},{40.425,-2},{40.425,-1.575}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));

      connect(thermostat.T, zoneMeanAirTemperature) annotation (Line(points={{70,-16},
              {88,-16},{88,0},{110,0}}, color={0,0,127}));
      connect(thermostat.port, roo.heaPorAir) annotation (Line(points={{50,-16},{26.25,
              -16},{26.25,-15}}, color={191,0,0}));
      connect(souInf.weaBus, sinInf.weaBus) annotation (Line(
          points={{-64,-33.88},{-76,-33.88},{-76,-34},{-90,-34},{-90,-20},{-24,-20},
              {-24,-19.88}},
          color={255,204,51},
          thickness=0.5));
      connect(souInf.ports[1], infMover.port_a) annotation (Line(points={{-52,-34},{
              -46,-34},{-46,-35},{-36,-35}}, color={0,127,255}));
      connect(product.y, infMover.m_flow_in) annotation (Line(points={{-39.5,-55},{-36,
              -55},{-36,-42},{-42,-42},{-42,-24},{-31.1,-24},{-31.1,-29}}, color={0,
              0,127}));
      connect(infMover.port_b, roo.ports[3]) annotation (Line(points={{-26,-35},{-18,
              -35},{-18,-36},{-6,-36},{-6,-60},{0,-60},{0,-20.5},{15.75,-20.5}},
            color={0,127,255}));
      annotation (
    experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          __Dymola_Algorithm="Radau"),
    __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/ThermalZones/Detailed/Validation/BESTEST/Case600FF.mos"
            "Simulate and plot"), Documentation(info="<html>
<p>
This model is used for the test case 600FF of the BESTEST validation suite.
Case 600FF is a light-weight building.
The room temperature is free floating.
</p>
</html>",     revisions="<html>
<ul>
<li>
October 29, 2016, by Michael Wetter:<br/>
Placed a capacity at the room-facing surface
to reduce the dimension of the nonlinear system of equations,
which generally decreases computing time.<br/>
Removed the pressure drop element which is not needed.<br/>
Linearized the radiative heat transfer, which is the default in
the library, and avoids a large nonlinear system of equations.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/565\">issue 565</a>.
</li>
<li>
December 22, 2014 by Michael Wetter:<br/>
Removed <code>Modelica.Fluid.System</code>
to address issue
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/311\">#311</a>.
</li>
<li>
October 9, 2013, by Michael Wetter:<br/>
Implemented soil properties using a record so that <code>TSol</code> and
<code>TLiq</code> are assigned.
This avoids an error when the model is checked in the pedantic mode.
</li>
<li>
July 15, 2012, by Michael Wetter:<br/>
Added reference results.
Changed implementation to make this model the base class
for all BESTEST cases.
Added computation of hourly and annual averaged room air temperature.
<li>
October 6, 2011, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
        Icon(graphics={
            Rectangle(
              extent={{-92,92},{92,-92}},
              pattern=LinePattern.None,
              lineColor={117,148,176},
              fillColor={170,213,255},
              fillPattern=FillPattern.Sphere),
            Rectangle(
              extent={{-100,-100},{100,100}},
              lineColor={95,95,95},
              fillColor={95,95,95},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-92,92},{92,-92}},
              pattern=LinePattern.None,
              lineColor={117,148,176},
              fillColor={170,213,255},
              fillPattern=FillPattern.Sphere)}),
        __Dymola_experimentSetupOutput(events=false));
    end Case600FF;

    model Case600_IdealHVAC
      extends Case600FF(roo(nPorts=5));
      Buildings.Fluid.Sensors.MassFlowRate supplyAirFlowCool(redeclare package
          Medium = MediumA)
        annotation (Placement(transformation(extent={{-56,38},{-36,58}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b supplyAirCool(
          redeclare package Medium = MediumA) "Fluid inlets and outlets"
        annotation (Placement(transformation(extent={{-70,60},{-50,140}}),
            iconTransformation(extent={{-20,100},{20,120}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b supplyAirHeat(
          redeclare package Medium = MediumA) "Fluid inlets and outlets"
        annotation (Placement(transformation(extent={{-40,60},{-20,140}}),
            iconTransformation(extent={{-70,100},{-30,120}})));
      Buildings.Fluid.Sensors.MassFlowRate supplyAirFlowHeat(redeclare package
          Medium = MediumA)
        annotation (Placement(transformation(extent={{-20,58},{0,78}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort supplyAirTempCool(redeclare
          package Medium = MediumA, m_flow_nominal=1,
        tau=30)
        annotation (Placement(transformation(extent={{-28,38},{-8,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort supplyAirTempHeat(redeclare
          package Medium = MediumA, m_flow_nominal=1,
        tau=30)
        annotation (Placement(transformation(extent={{4,58},{24,78}})));
      Modelica.Blocks.Sources.RealExpression heatingPowerCalc(y=
            supplyAirFlowHeat.m_flow*1005*(supplyAirTempHeat.T -
            zoneMeanAirTemperature))
        annotation (Placement(transformation(extent={{40,70},{60,90}})));
      Modelica.Blocks.Sources.RealExpression coolingPowerCalc(y=
            supplyAirFlowCool.m_flow*1005*(zoneMeanAirTemperature -
            supplyAirTempCool.T))
        annotation (Placement(transformation(extent={{40,50},{60,70}})));
      Modelica.Blocks.Interfaces.RealOutput coolingPower "HVAC cooling power"
        annotation (Placement(transformation(extent={{100,50},{120,70}})));
      Modelica.Blocks.Interfaces.RealOutput heatingPower "HVAC heating power"
        annotation (Placement(transformation(extent={{100,70},{120,90}})));
      Buildings.ThermalZones.Detailed.Validation.BESTEST.BaseClasses.DaySchedule
                              TSetHea(table=[0.0,273.15 + 20]) "Heating setpoint"
        annotation (Placement(transformation(extent={{66,-56},{74,-48}})));
      Buildings.ThermalZones.Detailed.Validation.BESTEST.BaseClasses.DaySchedule
                              TSetCoo(table=[0.0,273.15 + 27]) "Cooling setpoint"
        annotation (Placement(transformation(extent={{66,-78},{74,-70}})));
      Modelica.Blocks.Interfaces.RealOutput TcoolSetpoint "Cooling setpoint"
        annotation (Placement(transformation(extent={{100,-90},{120,-70}})));
      Modelica.Blocks.Interfaces.RealOutput TheatSetpoint "Heating setpoint"
        annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
    equation
      connect(supplyAirCool, supplyAirFlowCool.port_a) annotation (Line(points=
              {{-60,100},{-60,100},{-60,48},{-56,48}}, color={0,127,255}));
      connect(supplyAirFlowCool.port_b, supplyAirTempCool.port_a) annotation (
          Line(points={{-36,48},{-32,48},{-28,48}}, color={0,127,255}));
      connect(supplyAirHeat, supplyAirFlowHeat.port_a) annotation (Line(points=
              {{-30,100},{-30,68},{-20,68}}, color={0,127,255}));
      connect(supplyAirFlowHeat.port_b, supplyAirTempHeat.port_a)
        annotation (Line(points={{0,68},{2,68},{4,68}}, color={0,127,255}));
      connect(supplyAirTempCool.port_b, roo.ports[4]) annotation (Line(points={
              {-8,48},{4,48},{4,-22.5},{15.75,-22.5}}, color={0,127,255}));
      connect(supplyAirTempHeat.port_b, roo.ports[5]) annotation (Line(points={
              {24,68},{28,68},{28,4},{6,4},{6,-22.5},{15.75,-22.5}}, color={0,
              127,255}));
      connect(heatingPowerCalc.y, heatingPower)
        annotation (Line(points={{61,80},{110,80},{110,80}}, color={0,0,127}));
      connect(coolingPowerCalc.y, coolingPower)
        annotation (Line(points={{61,60},{110,60},{110,60}}, color={0,0,127}));
      connect(TSetHea.y[1], TheatSetpoint) annotation (Line(points={{74.4,-52},
              {86,-52},{86,-60},{110,-60}}, color={0,0,127}));
      connect(TSetCoo.y[1], TcoolSetpoint) annotation (Line(points={{74.4,-74},
              {86,-74},{86,-80},{110,-80}}, color={0,0,127}));
    end Case600_IdealHVAC;

    model Case600_AirHVAC
      "BESTest Case 600 with fluid ports for air HVAC"
      extends Case600FF(roo(nPorts=5));
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      Modelica.Blocks.Interfaces.RealOutput TcoolSetpoint "Cooling setpoint"
        annotation (Placement(transformation(extent={{100,-90},{120,-70}})));
      Modelica.Blocks.Interfaces.RealOutput TheatSetpoint "Heating setpoint"
        annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b supplyAir(redeclare
          package Medium = MediumA) "Supply air port" annotation (Placement(
            transformation(extent={{-70,60},{-50,140}}), iconTransformation(extent={{-60,100},
                {-20,120}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b returnAir(redeclare
          package Medium = MediumA) "Return air port" annotation (Placement(
            transformation(extent={{-40,60},{-20,140}}), iconTransformation(extent={{0,100},
                {40,120}})));
      Buildings.Fluid.Sensors.MassFlowRate supplyAirFlow(redeclare package Medium =
            MediumA)
        annotation (Placement(transformation(extent={{-56,38},{-36,58}})));
      Buildings.Fluid.Sensors.MassFlowRate returnAirFlow(redeclare package Medium =
            MediumA)
        annotation (Placement(transformation(extent={{-20,58},{0,78}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort supplyAirTemp(redeclare
          package
          Medium = MediumA, m_flow_nominal=designAirFlow,
        tau=30)
        annotation (Placement(transformation(extent={{-28,38},{-8,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort returnAirTemp(redeclare
          package
          Medium = MediumA, m_flow_nominal=designAirFlow,
        tau=30)
        annotation (Placement(transformation(extent={{4,58},{24,78}})));
      Buildings.ThermalZones.Detailed.Validation.BESTEST.BaseClasses.DaySchedule
                              TSetHea(table=[0.0,273.15 + 20]) "Heating setpoint"
        annotation (Placement(transformation(extent={{70,-62},{78,-54}})));
      Buildings.ThermalZones.Detailed.Validation.BESTEST.BaseClasses.DaySchedule
                              TSetCoo(table=[0.0,273.15 + 27]) "Cooling setpoint"
        annotation (Placement(transformation(extent={{70,-84},{78,-76}})));
    equation
      connect(supplyAir, supplyAirFlow.port_a)
        annotation (Line(points={{-60,100},{-60,48},{-56,48}}, color={0,127,255}));
      connect(returnAir, returnAirFlow.port_a) annotation (Line(points={{-30,100},{-30,
              84},{-20,84},{-20,68}}, color={0,127,255}));
      connect(supplyAirFlow.port_b, supplyAirTemp.port_a)
        annotation (Line(points={{-36,48},{-28,48}}, color={0,127,255}));
      connect(supplyAirTemp.port_b, roo.ports[4]) annotation (Line(points={{-8,48},{
              -8,48},{-8,-18},{-8,-22.5},{15.75,-22.5}}, color={0,127,255}));
      connect(returnAirFlow.port_b, returnAirTemp.port_a)
        annotation (Line(points={{0,68},{2,68},{4,68}}, color={0,127,255}));
      connect(returnAirTemp.port_b, roo.ports[5]) annotation (Line(points={{24,68},{
              30,68},{30,10},{-2,10},{-2,-22.5},{15.75,-22.5}}, color={0,127,255}));
      connect(TSetHea.y[1], TheatSetpoint) annotation (Line(points={{78.4,-58},
              {90,-58},{90,-60},{110,-60}}, color={0,0,127}));
      connect(TSetCoo.y[1], TcoolSetpoint) annotation (Line(points={{78.4,-80},
              {110,-80}},           color={0,0,127}));
    end Case600_AirHVAC;

    model Case610FF
      extends Case600FF(roo(
         datConExtWin(
          ove(
            wR={0.5},
            wL={0.5},
            dep={1},
            gap={0.5}))));
    end Case610FF;

    model Case610_IdealAirHVAC
      "BESTest Case 610 with fluid ports for ideal air HVAC"
      extends Case610FF(roo(nPorts=5),
        InfiltrationRate(k=48*2.7*0.5/3600));
      Modelica.Blocks.Interfaces.RealOutput TcoolSetpoint "Cooling setpoint"
        annotation (Placement(transformation(extent={{100,-90},{120,-70}})));
      Modelica.Blocks.Interfaces.RealOutput TheatSetpoint "Heating setpoint"
        annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b supplyAirCool(
          redeclare package Medium = MediumA) "Fluid inlets and outlets"
        annotation (Placement(transformation(extent={{-70,60},{-50,140}}),
            iconTransformation(extent={{-20,100},{20,120}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b supplyAirHeat(
          redeclare package Medium = MediumA) "Fluid inlets and outlets"
        annotation (Placement(transformation(extent={{-40,60},{-20,140}}),
            iconTransformation(extent={{-70,100},{-30,120}})));
      Buildings.Fluid.Sensors.MassFlowRate supplyAirFlowCool(redeclare package
          Medium = MediumA)
        annotation (Placement(transformation(extent={{-56,38},{-36,58}})));
      Buildings.Fluid.Sensors.MassFlowRate supplyAirFlowHeat(redeclare package
          Medium = MediumA)
        annotation (Placement(transformation(extent={{-20,58},{0,78}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort supplyAirTempCool(redeclare
          package Medium = MediumA, m_flow_nominal=1)
        annotation (Placement(transformation(extent={{-28,38},{-8,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort supplyAirTempHeat(redeclare
          package Medium = MediumA, m_flow_nominal=1)
        annotation (Placement(transformation(extent={{4,58},{24,78}})));
      Modelica.Blocks.Sources.RealExpression coolingPowerCalc(y=
            supplyAirFlowCool.m_flow*1005*(zoneMeanAirTemperature -
            supplyAirTempCool.T))
        annotation (Placement(transformation(extent={{40,50},{60,70}})));
      Modelica.Blocks.Sources.RealExpression heatingPowerCalc(y=
            supplyAirFlowHeat.m_flow*1005*(supplyAirTempHeat.T -
            zoneMeanAirTemperature))
        annotation (Placement(transformation(extent={{40,70},{60,90}})));
      Modelica.Blocks.Interfaces.RealOutput heatingPower "HVAC heating power"
        annotation (Placement(transformation(extent={{100,70},{120,90}})));
      Modelica.Blocks.Interfaces.RealOutput coolingPower "HVAC cooling power"
        annotation (Placement(transformation(extent={{100,50},{120,70}})));
      Buildings.ThermalZones.Detailed.Validation.BESTEST.BaseClasses.DaySchedule
                              TSetHea(table=[0.0,273.15 + 20]) "Heating setpoint"
        annotation (Placement(transformation(extent={{66,-56},{74,-48}})));
      Buildings.ThermalZones.Detailed.Validation.BESTEST.BaseClasses.DaySchedule
                              TSetCoo(table=[0.0,273.15 + 27]) "Cooling setpoint"
        annotation (Placement(transformation(extent={{66,-78},{74,-70}})));
    equation
      connect(supplyAirCool, supplyAirFlowCool.port_a) annotation (Line(points=
              {{-60,100},{-60,48},{-56,48}}, color={0,127,255}));
      connect(supplyAirHeat, supplyAirFlowHeat.port_a) annotation (Line(points=
              {{-30,100},{-30,84},{-20,84},{-20,68}}, color={0,127,255}));
      connect(supplyAirFlowCool.port_b, supplyAirTempCool.port_a)
        annotation (Line(points={{-36,48},{-28,48}}, color={0,127,255}));
      connect(supplyAirFlowHeat.port_b, supplyAirTempHeat.port_a)
        annotation (Line(points={{0,68},{2,68},{4,68}}, color={0,127,255}));
      connect(heatingPowerCalc.y, heatingPower)
        annotation (Line(points={{61,80},{110,80}}, color={0,0,127}));
      connect(coolingPowerCalc.y, coolingPower)
        annotation (Line(points={{61,60},{110,60}}, color={0,0,127}));
      connect(TSetHea.y[1], TheatSetpoint) annotation (Line(points={{74.4,-52},
              {88,-52},{88,-60},{110,-60}}, color={0,0,127}));
      connect(TSetCoo.y[1], TcoolSetpoint) annotation (Line(points={{74.4,-74},
              {88,-74},{88,-80},{110,-80}}, color={0,0,127}));
      connect(supplyAirTempCool.port_b, roo.ports[4]) annotation (Line(points={
              {-8,48},{-8,48},{-8,12},{-8,-22.5},{15.75,-22.5}}, color={0,127,
              255}));
      connect(supplyAirTempHeat.port_b, roo.ports[5]) annotation (Line(points={
              {24,68},{24,4},{-2,4},{-2,-22.5},{15.75,-22.5}}, color={0,127,255}));
    end Case610_IdealAirHVAC;

    model Case610_AirHVAC
      "BESTest Case 610 with fluid ports for air HVAC"
      extends Case610FF(roo(nPorts=5));
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      Modelica.Blocks.Interfaces.RealOutput TcoolSetpoint "Cooling setpoint"
        annotation (Placement(transformation(extent={{100,-90},{120,-70}})));
      Modelica.Blocks.Interfaces.RealOutput TheatSetpoint "Heating setpoint"
        annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b supplyAir(redeclare
          package Medium = MediumA) "Supply air port" annotation (Placement(
            transformation(extent={{-70,60},{-50,140}}), iconTransformation(extent={{-60,100},
                {-20,120}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b returnAir(redeclare
          package Medium = MediumA) "Return air port" annotation (Placement(
            transformation(extent={{-40,60},{-20,140}}), iconTransformation(extent={{0,100},
                {40,120}})));
      Buildings.Fluid.Sensors.MassFlowRate supplyAirFlow(redeclare package Medium =
            MediumA)
        annotation (Placement(transformation(extent={{-56,38},{-36,58}})));
      Buildings.Fluid.Sensors.MassFlowRate returnAirFlow(redeclare package Medium =
            MediumA)
        annotation (Placement(transformation(extent={{-20,58},{0,78}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort supplyAirTemp(redeclare
          package
          Medium = MediumA, m_flow_nominal=designAirFlow)
        annotation (Placement(transformation(extent={{-28,38},{-8,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort returnAirTemp(redeclare
          package
          Medium = MediumA, m_flow_nominal=designAirFlow)
        annotation (Placement(transformation(extent={{4,58},{24,78}})));
      Buildings.ThermalZones.Detailed.Validation.BESTEST.BaseClasses.DaySchedule
                              TSetHea(table=[0.0,273.15 + 20]) "Heating setpoint"
        annotation (Placement(transformation(extent={{70,-62},{78,-54}})));
      Buildings.ThermalZones.Detailed.Validation.BESTEST.BaseClasses.DaySchedule
                              TSetCoo(table=[0.0,273.15 + 27]) "Cooling setpoint"
        annotation (Placement(transformation(extent={{70,-84},{78,-76}})));
    equation
      connect(supplyAir, supplyAirFlow.port_a)
        annotation (Line(points={{-60,100},{-60,48},{-56,48}}, color={0,127,255}));
      connect(returnAir, returnAirFlow.port_a) annotation (Line(points={{-30,100},{-30,
              84},{-20,84},{-20,68}}, color={0,127,255}));
      connect(supplyAirFlow.port_b, supplyAirTemp.port_a)
        annotation (Line(points={{-36,48},{-28,48}}, color={0,127,255}));
      connect(supplyAirTemp.port_b, roo.ports[4]) annotation (Line(points={{-8,48},{
              -8,48},{-8,-18},{-8,-22.5},{15.75,-22.5}}, color={0,127,255}));
      connect(returnAirFlow.port_b, returnAirTemp.port_a)
        annotation (Line(points={{0,68},{2,68},{4,68}}, color={0,127,255}));
      connect(returnAirTemp.port_b, roo.ports[5]) annotation (Line(points={{24,68},{
              30,68},{30,10},{-2,10},{-2,-22.5},{15.75,-22.5}}, color={0,127,255}));
      connect(TSetHea.y[1], TheatSetpoint) annotation (Line(points={{78.4,-58},
              {90,-58},{90,-60},{110,-60}}, color={0,0,127}));
      connect(TSetCoo.y[1], TcoolSetpoint) annotation (Line(points={{78.4,-80},
              {110,-80}},           color={0,0,127}));
    end Case610_AirHVAC;

    model Case610_AirHVAC_SupplyOnly
      "BESTest Case 610 with fluid ports for air HVAC"
      extends Case610FF(roo(nPorts=4));
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      Schedules.heatingSetpointSchedule heatingSetpointSchedule
        annotation (Placement(transformation(extent={{12,-72},{32,-52}})));
      Schedules.coolingSetpointSchedule coolingSetpointSchedule
        annotation (Placement(transformation(extent={{12,-100},{32,-80}})));
      Modelica.Blocks.Interfaces.RealOutput TcoolSetpoint "Cooling setpoint"
        annotation (Placement(transformation(extent={{100,-90},{120,-70}})));
      Modelica.Blocks.Interfaces.RealOutput TheatSetpoint "Heating setpoint"
        annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b supplyAir(redeclare
          package Medium = MediumA) "Supply air port" annotation (Placement(
            transformation(extent={{-70,60},{-50,140}}), iconTransformation(extent={{-60,100},
                {-20,120}})));
      Buildings.Fluid.Sensors.MassFlowRate supplyAirFlow(redeclare package
          Medium =
            MediumA)
        annotation (Placement(transformation(extent={{-56,38},{-36,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort supplyAirTemp(redeclare
          package Medium =
                   MediumA, m_flow_nominal=designAirFlow)
        annotation (Placement(transformation(extent={{-28,38},{-8,58}})));
    equation
      connect(heatingSetpointSchedule.y[1], TheatSetpoint) annotation (Line(points={
              {33,-62},{70,-62},{70,-60},{110,-60}}, color={0,0,127}));
      connect(coolingSetpointSchedule.y[1], TcoolSetpoint) annotation (Line(points={
              {33,-90},{68,-90},{68,-80},{110,-80}}, color={0,0,127}));
      connect(supplyAir, supplyAirFlow.port_a)
        annotation (Line(points={{-60,100},{-60,48},{-56,48}}, color={0,127,255}));
      connect(supplyAirFlow.port_b, supplyAirTemp.port_a)
        annotation (Line(points={{-36,48},{-28,48}}, color={0,127,255}));
      connect(supplyAirTemp.port_b, roo.ports[4]) annotation (Line(points={{-8,48},{
              -8,48},{-8,-18},{-8,-22.5},{15.75,-22.5}}, color={0,127,255}));
    end Case610_AirHVAC_SupplyOnly;

    model Case610FF_NoInf
      "Basic test with light-weight construction and free floating temperature"
      package MediumA = Buildings.Media.Air "Medium model";
      parameter Modelica.SIunits.Angle lat "Building latitude";
      parameter Modelica.SIunits.Angle S_=
        Buildings.Types.Azimuth.S "Azimuth for south walls";
      parameter Modelica.SIunits.Angle E_=
        Buildings.Types.Azimuth.E "Azimuth for east walls";
      parameter Modelica.SIunits.Angle W_=
        Buildings.Types.Azimuth.W "Azimuth for west walls";
      parameter Modelica.SIunits.Angle N_=
        Buildings.Types.Azimuth.N "Azimuth for north walls";
      parameter Modelica.SIunits.Angle C_=
        Buildings.Types.Tilt.Ceiling "Tilt for ceiling";
      parameter Modelica.SIunits.Angle F_=
        Buildings.Types.Tilt.Floor "Tilt for floor";
      parameter Modelica.SIunits.Angle Z_=
        Buildings.Types.Tilt.Wall "Tilt for wall";
      parameter Integer nConExtWin = 1 "Number of constructions with a window";
      parameter Integer nConBou = 1
        "Number of surface that are connected to constructions that are modeled inside the room";
      parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic matExtWal(
        nLay=3,
        absIR_a=0.9,
        absIR_b=0.9,
        absSol_a=0.6,
        absSol_b=0.6,
        material={Buildings.HeatTransfer.Data.Solids.Generic(
            x=0.009,
            k=0.140,
            c=900,
            d=530,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef),
                             Buildings.HeatTransfer.Data.Solids.Generic(
            x=0.066,
            k=0.040,
            c=840,
            d=12,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef),
                             Buildings.HeatTransfer.Data.Solids.Generic(
            x=0.012,
            k=0.160,
            c=840,
            d=950,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef)})
                               "Exterior wall"
        annotation (Placement(transformation(extent={{20,84},{34,98}})));
      parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic
                                                              matFlo(final nLay=
               2,
        absIR_a=0.9,
        absIR_b=0.9,
        absSol_a=0.6,
        absSol_b=0.6,
        material={Buildings.HeatTransfer.Data.Solids.Generic(
            x=1.003,
            k=0.040,
            c=0,
            d=0,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef),
                             Buildings.HeatTransfer.Data.Solids.Generic(
            x=0.025,
            k=0.140,
            c=1200,
            d=650,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef)})
                               "Floor"
        annotation (Placement(transformation(extent={{80,84},{94,98}})));
       parameter Buildings.HeatTransfer.Data.Solids.Generic soil(
        x=2,
        k=1.3,
        c=800,
        d=1500) "Soil properties"
        annotation (Placement(transformation(extent={{40,40},{60,60}})));

      Buildings.ThermalZones.Detailed.MixedAir roo(
        redeclare package Medium = MediumA,
        hRoo=2.7,
        nConExtWin=nConExtWin,
        nConBou=1,
        energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
        AFlo=48,
        datConBou(
          layers={matFlo},
          each A=48,
          each til=F_),
        datConExt(
          layers={roof,matExtWal,matExtWal,matExtWal},
          A={48,6*2.7,6*2.7,8*2.7},
          til={C_,Z_,Z_,Z_},
          azi={S_,W_,E_,N_}),
        nConExt=4,
        nConPar=0,
        nSurBou=0,
        datConExtWin(
          layers={matExtWal},
          A={8*2.7},
          glaSys={window600},
          wWin={2*3},
          hWin={2},
          fFra={0.001},
          til={Z_},
          azi={S_},
          ove(wR={0.5},
              wL={0.5},
              dep={1},
              gap={0.5})),
        massDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
        lat=lat)
        "Room model for Case 600"
        annotation (Placement(transformation(extent={{12,-30},{42,0}})));
      Modelica.Blocks.Sources.Constant qConGai_flow(k=80/48) "Convective heat gain"
        annotation (Placement(transformation(extent={{-78,-6},{-70,2}})));
      Modelica.Blocks.Sources.Constant qRadGai_flow(k=120/48) "Radiative heat gain"
        annotation (Placement(transformation(extent={{-66,2},{-58,10}})));
      Modelica.Blocks.Routing.Multiplex3 multiplex3_1
        annotation (Placement(transformation(extent={{-40,-6},{-32,2}})));
      Modelica.Blocks.Sources.Constant qLatGai_flow(k=0) "Latent heat gain"
        annotation (Placement(transformation(extent={{-66,-14},{-58,-6}})));
      Modelica.Blocks.Sources.Constant uSha(k=0)
        "Control signal for the shading device"
        annotation (Placement(transformation(extent={{-50,6},{-42,14}})));
      Modelica.Blocks.Routing.Replicator replicator(nout=max(1,nConExtWin))
        annotation (Placement(transformation(extent={{-34,6},{-26,14}})));
      Modelica.Thermal.HeatTransfer.Sources.FixedTemperature TSoi[nConBou](each T=
            283.15) "Boundary condition for construction"
                                              annotation (Placement(transformation(
            extent={{0,0},{-8,8}},
            origin={48,-52})));
      parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic roof(nLay=3,
        absIR_a=0.9,
        absIR_b=0.9,
        absSol_a=0.6,
        absSol_b=0.6,
        material={Buildings.HeatTransfer.Data.Solids.Generic(
            x=0.019,
            k=0.140,
            c=900,
            d=530,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef),
                             Buildings.HeatTransfer.Data.Solids.Generic(
            x=0.1118,
            k=0.040,
            c=840,
            d=12,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef),
                             Buildings.HeatTransfer.Data.Solids.Generic(
            x=0.010,
            k=0.160,
            c=840,
            d=950,
            nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef)})
                               "Roof"
        annotation (Placement(transformation(extent={{60,84},{74,98}})));
      Buildings.ThermalZones.Detailed.Validation.BESTEST.Data.Win600
             window600(
        UFra=3,
        haveExteriorShade=false,
        haveInteriorShade=false) "Window"
        annotation (Placement(transformation(extent={{40,84},{54,98}})));
      Buildings.HeatTransfer.Conduction.SingleLayer soi(
        A=48,
        material=soil,
        steadyStateInitial=true,
        stateAtSurface_a=false,
        stateAtSurface_b=true,
        T_a_start=283.15,
        T_b_start=283.75) "2m deep soil (per definition on p.4 of ASHRAE 140-2007)"
        annotation (Placement(transformation(
            extent={{5,-5},{-3,3}},
            rotation=-90,
            origin={33,-35})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus
        annotation (Placement(transformation(extent={{-98,96},{-82,112}})));
      replaceable parameter
        Buildings.ThermalZones.Detailed.Validation.BESTEST.Data.StandardResultsFreeFloating
          staRes(
            minT( Min=-18.8+273.15, Max=-15.6+273.15, Mean=-17.6+273.15),
            maxT( Min=64.9+273.15,  Max=69.5+273.15,  Mean=66.2+273.15),
            meanT(Min=24.2+273.15,  Max=25.9+273.15,  Mean=25.1+273.15))
              constrainedby Modelica.Icons.Record
        "Reference results from ASHRAE/ANSI Standard 140"
        annotation (Placement(transformation(extent={{80,40},{94,54}})));

      Modelica.Blocks.Interfaces.RealOutput zoneMeanAirTemperature
        "Zone mean air drybulb temperature"
        annotation (Placement(transformation(extent={{100,-10},{120,10}})));
      Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor thermostat
        annotation (Placement(transformation(extent={{50,-26},{70,-6}})));
    equation
      connect(qRadGai_flow.y,multiplex3_1. u1[1])  annotation (Line(
          points={{-57.6,6},{-56,6},{-56,0.8},{-40.8,0.8}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(qLatGai_flow.y,multiplex3_1. u3[1])  annotation (Line(
          points={{-57.6,-10},{-50,-10},{-50,-4.8},{-40.8,-4.8}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(multiplex3_1.y, roo.qGai_flow) annotation (Line(
          points={{-31.6,-2},{-22,-2},{-22,-9},{10.8,-9}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(roo.uSha, replicator.y) annotation (Line(
          points={{10.8,-1.5},{-18,-1.5},{-18,10},{-25.6,10}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(qConGai_flow.y, multiplex3_1.u2[1]) annotation (Line(
          points={{-69.6,-2},{-40.8,-2}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(uSha.y, replicator.u) annotation (Line(
          points={{-41.6,10},{-34.8,10}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(TSoi[1].port, soi.port_a) annotation (Line(
          points={{40,-48},{32,-48},{32,-40}},
          color={191,0,0},
          smooth=Smooth.None));
      connect(soi.port_b, roo.surf_conBou[1]) annotation (Line(
          points={{32,-32},{32,-27},{31.5,-27}},
          color={191,0,0},
          smooth=Smooth.None));

      connect(weaBus, roo.weaBus) annotation (Line(
          points={{-90,104},{-90,104},{-90,20},{40,20},{40,-2},{40.425,-2},{40.425,-1.575}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));

      connect(thermostat.T, zoneMeanAirTemperature) annotation (Line(points={{70,-16},
              {88,-16},{88,0},{110,0}}, color={0,0,127}));
      connect(thermostat.port, roo.heaPorAir) annotation (Line(points={{50,-16},{26.25,
              -16},{26.25,-15}}, color={191,0,0}));
      annotation (
    experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          __Dymola_Algorithm="Radau"),
    __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/ThermalZones/Detailed/Validation/BESTEST/Case600FF.mos"
            "Simulate and plot"), Documentation(info="<html>
<p>
This model is used for the test case 600FF of the BESTEST validation suite.
Case 600FF is a light-weight building.
The room temperature is free floating.
</p>
</html>",     revisions="<html>
<ul>
<li>
October 29, 2016, by Michael Wetter:<br/>
Placed a capacity at the room-facing surface
to reduce the dimension of the nonlinear system of equations,
which generally decreases computing time.<br/>
Removed the pressure drop element which is not needed.<br/>
Linearized the radiative heat transfer, which is the default in
the library, and avoids a large nonlinear system of equations.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/565\">issue 565</a>.
</li>
<li>
December 22, 2014 by Michael Wetter:<br/>
Removed <code>Modelica.Fluid.System</code>
to address issue
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/311\">#311</a>.
</li>
<li>
October 9, 2013, by Michael Wetter:<br/>
Implemented soil properties using a record so that <code>TSol</code> and
<code>TLiq</code> are assigned.
This avoids an error when the model is checked in the pedantic mode.
</li>
<li>
July 15, 2012, by Michael Wetter:<br/>
Added reference results.
Changed implementation to make this model the base class
for all BESTEST cases.
Added computation of hourly and annual averaged room air temperature.
<li>
October 6, 2011, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
        Icon(graphics={
            Rectangle(
              extent={{-92,92},{92,-92}},
              pattern=LinePattern.None,
              lineColor={117,148,176},
              fillColor={170,213,255},
              fillPattern=FillPattern.Sphere),
            Rectangle(
              extent={{-100,-100},{100,100}},
              lineColor={95,95,95},
              fillColor={95,95,95},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-92,92},{92,-92}},
              pattern=LinePattern.None,
              lineColor={117,148,176},
              fillColor={170,213,255},
              fillPattern=FillPattern.Sphere)}),
        __Dymola_experimentSetupOutput(events=false));
    end Case610FF_NoInf;

    model Case610_NoInf_AirHVAC
      extends Case610FF_NoInf(roo(nPorts=2));
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b supplyAir(redeclare
          package Medium = MediumA) "Supply air port" annotation (Placement(
            transformation(extent={{-66,60},{-46,140}}), iconTransformation(extent={{-60,100},
                {-20,120}})));
      Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b returnAir(redeclare
          package Medium = MediumA) "Return air port" annotation (Placement(
            transformation(extent={{-36,60},{-16,140}}), iconTransformation(extent={{0,100},
                {40,120}})));
      Buildings.Fluid.Sensors.MassFlowRate supplyAirFlow(redeclare package Medium =
            MediumA)
        annotation (Placement(transformation(extent={{-52,38},{-32,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort supplyAirTemp(redeclare
          package
          Medium = MediumA, m_flow_nominal=designAirFlow)
        annotation (Placement(transformation(extent={{-24,38},{-4,58}})));
      Buildings.Fluid.Sensors.MassFlowRate returnAirFlow(redeclare package Medium =
            MediumA)
        annotation (Placement(transformation(extent={{-16,58},{4,78}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort returnAirTemp(redeclare
          package
          Medium = MediumA, m_flow_nominal=designAirFlow)
        annotation (Placement(transformation(extent={{8,58},{28,78}})));
      Buildings.ThermalZones.Detailed.Validation.BESTEST.BaseClasses.DaySchedule
                              TSetHea(table=[0.0,273.15 + 20]) "Heating setpoint"
        annotation (Placement(transformation(extent={{74,-64},{82,-56}})));
      Buildings.ThermalZones.Detailed.Validation.BESTEST.BaseClasses.DaySchedule
                              TSetCoo(table=[0.0,273.15 + 27]) "Cooling setpoint"
        annotation (Placement(transformation(extent={{74,-84},{82,-76}})));
      Modelica.Blocks.Interfaces.RealOutput TcoolSetpoint "Cooling setpoint"
        annotation (Placement(transformation(extent={{100,-90},{120,-70}})));
      Modelica.Blocks.Interfaces.RealOutput TheatSetpoint "Heating setpoint"
        annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
    equation
      connect(TSetHea.y[1], TheatSetpoint) annotation (Line(points={{82.4,-60},{82.4,
              -60},{110,-60}}, color={0,0,127}));
      connect(TSetCoo.y[1], TcoolSetpoint) annotation (Line(points={{82.4,-80},{110,
              -80},{110,-80}}, color={0,0,127}));
      connect(supplyAir, supplyAirFlow.port_a) annotation (Line(points={{-56,100},{-58,
              100},{-58,48},{-52,48}}, color={0,127,255}));
      connect(supplyAirFlow.port_b, supplyAirTemp.port_a)
        annotation (Line(points={{-32,48},{-24,48}}, color={0,127,255}));
      connect(supplyAirTemp.port_b, roo.ports[1]) annotation (Line(points={{-4,48},{
              0,48},{0,-22.5},{15.75,-22.5}}, color={0,127,255}));
      connect(returnAir, returnAirFlow.port_a) annotation (Line(points={{-26,100},{-26,
              100},{-26,68},{-16,68}}, color={0,127,255}));
      connect(returnAirFlow.port_b, returnAirTemp.port_a)
        annotation (Line(points={{4,68},{6,68},{8,68}}, color={0,127,255}));
      connect(returnAirTemp.port_b, roo.ports[2]) annotation (Line(points={{28,68},{
              32,68},{32,66},{32,38},{32,8},{6,8},{6,-22.5},{15.75,-22.5}}, color={0,
              127,255}));
    end Case610_NoInf_AirHVAC;
  end ThermalEnvelope;

  package Schedules "Package containing schedules"

    model coolingSetpointSchedule
      "Schedule of cooling setpoint temperature"
      extends Modelica.Blocks.Sources.CombiTimeTable(
        extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
        table=[0,30+273.15; 8*3600,30+273.15; 8*3600,25+273.15; 18*3600,25+273.15; 18*3600,30+273.15; 24*3600,30+273.15],
        columns={2});
    end coolingSetpointSchedule;

    model heatingSetpointSchedule
      "Schedule of heating setpoint temperature"
      extends Modelica.Blocks.Sources.CombiTimeTable(
        extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
        table=[0,15+273.15; 8*3600,15+273.15; 8*3600,20+273.15; 18*3600,20+273.15; 18*3600,15+273.15; 24*3600,15+273.15],
        columns={2});
    end heatingSetpointSchedule;
  end Schedules;

  package HVACSystems "Package containing HVAC models and controls"

    model IdealAir_P "Simple ideal heating and cooling"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      parameter Real sensitivityGainHeat "[K] Control gain for heating";
      parameter Real sensitivityGainCool "[K] Control gain for cooling";
      Modelica.Blocks.Interfaces.RealInput Tmea
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{-20,-20},{20,20}},
            rotation=0,
            origin={-120,-40})));
      Buildings.Fluid.Sources.MassFlowSource_T coolSupplyAir(use_m_flow_in=true,
        redeclare package Medium = MediumA,
        nPorts=1,
        T=286.15)
        annotation (Placement(transformation(extent={{20,20},{40,40}})));
      Buildings.Fluid.Sources.MassFlowSource_T heatSupplyAir(use_m_flow_in=true,
        redeclare package Medium = MediumA,
        nPorts=1,
        T=323.15)
        annotation (Placement(transformation(extent={{20,60},{40,80}})));
      Modelica.Fluid.Interfaces.FluidPorts_b supplyAirHeat[1](redeclare package
          Medium = MediumA) "Heating supply air"
        annotation (Placement(transformation(extent={{94,20},{114,100}})));
      Modelica.Blocks.Math.Gain heatGain(k=sensitivityGainHeat)
        annotation (Placement(transformation(extent={{-40,60},{-20,80}})));
      Modelica.Blocks.Math.Gain coolGain(k=-sensitivityGainCool)
        annotation (Placement(transformation(extent={{-40,20},{-20,40}})));
      Modelica.Blocks.Interfaces.RealInput TheatSetpoint
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-120,70})));
      Modelica.Blocks.Interfaces.RealInput TcoolSetpoint
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-120,30})));
      Modelica.Blocks.Math.Feedback feedback
        annotation (Placement(transformation(extent={{-70,60},{-50,80}})));
      Modelica.Blocks.Math.Feedback feedback1
        annotation (Placement(transformation(extent={{-90,20},{-70,40}})));
      Modelica.Fluid.Interfaces.FluidPorts_b supplyAirCool[1](redeclare package
          Medium = MediumA) "Cooling supply air"
        annotation (Placement(transformation(extent={{94,-26},{114,54}})));
      Modelica.Blocks.Nonlinear.Limiter limiter(uMin=0)
        annotation (Placement(transformation(extent={{-10,20},{10,40}})));
      Modelica.Blocks.Nonlinear.Limiter limiter1(uMin=0)
        annotation (Placement(transformation(extent={{-10,60},{10,80}})));
    equation
      connect(TheatSetpoint, feedback.u1)
        annotation (Line(points={{-120,70},{-68,70}}, color={0,0,127}));
      connect(Tmea, feedback.u2) annotation (Line(points={{-120,-40},{-96,-40},
              {-60,-40},{-60,62}}, color={0,0,127}));
      connect(feedback.y, heatGain.u) annotation (Line(points={{-51,70},{-51,70},
              {-42,70}}, color={0,0,127}));
      connect(TcoolSetpoint, feedback1.u1)
        annotation (Line(points={{-120,30},{-88,30}}, color={0,0,127}));
      connect(Tmea, feedback1.u2) annotation (Line(points={{-120,-40},{-80,-40},
              {-80,22}}, color={0,0,127}));
      connect(feedback1.y, coolGain.u) annotation (Line(points={{-71,30},{-56.5,
              30},{-42,30}}, color={0,0,127}));
      connect(heatSupplyAir.ports[1:1], supplyAirHeat) annotation (Line(points=
              {{40,70},{104,70},{104,60}}, color={0,127,255}));
      connect(coolSupplyAir.ports[1:1], supplyAirCool) annotation (Line(points=
              {{40,30},{66,30},{66,14},{104,14}}, color={0,127,255}));
      connect(coolGain.y, limiter.u)
        annotation (Line(points={{-19,30},{-12,30}}, color={0,0,127}));
      connect(limiter.y, coolSupplyAir.m_flow_in) annotation (Line(points={{11,
              30},{14,30},{14,38},{20,38}}, color={0,0,127}));
      connect(heatGain.y, limiter1.u) annotation (Line(points={{-19,70},{-16,70},
              {-12,70}}, color={0,0,127}));
      connect(limiter1.y, heatSupplyAir.m_flow_in) annotation (Line(points={{11,
              70},{14,70},{14,78},{20,78}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end IdealAir_P;

    model IdealAir_PI "Simple ideal heating and cooling"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      Modelica.Blocks.Interfaces.RealInput Tmea
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{-20,-20},{20,20}},
            rotation=0,
            origin={-120,-40})));
      Buildings.Fluid.Sources.MassFlowSource_T coolSupplyAir(use_m_flow_in=true,
        redeclare package Medium = MediumA,
        T=287.15,
        nPorts=1)
        annotation (Placement(transformation(extent={{20,20},{40,40}})));
      Buildings.Fluid.Sources.MassFlowSource_T heatSupplyAir(use_m_flow_in=true,
        redeclare package Medium = MediumA,
        nPorts=1,
        T=313.15)
        annotation (Placement(transformation(extent={{20,60},{40,80}})));
      Buildings.Fluid.Sources.FixedBoundary bou(
        redeclare package Medium = MediumA,
        nPorts=1,
        p(displayUnit="Pa") = 101325)
        annotation (Placement(transformation(extent={{-60,-70},{-40,-50}})));
      Modelica.Fluid.Interfaces.FluidPorts_b supplyAirHeat[1](redeclare package
          Medium = MediumA) "Heating supply air"
        annotation (Placement(transformation(extent={{94,20},{114,100}})));
      Modelica.Fluid.Interfaces.FluidPorts_b returnAir[1](redeclare package
          Medium = MediumA)                               "Return air"
        annotation (Placement(transformation(extent={{94,-100},{114,-20}})));
      Modelica.Blocks.Math.Gain coolGain(k=-1)
        annotation (Placement(transformation(extent={{-20,20},{0,40}})));
      Modelica.Blocks.Interfaces.RealInput TheatSetpoint
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-120,70})));
      Modelica.Blocks.Interfaces.RealInput TcoolSetpoint
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-120,30})));
      Modelica.Fluid.Interfaces.FluidPorts_b supplyAirCool[1](redeclare package
          Medium = MediumA) "Cooling supply air"
        annotation (Placement(transformation(extent={{94,-26},{114,54}})));
      Buildings.Controls.Continuous.LimPID conPID(
        Ti=0.1,
        Td=0,
        yMax=0,
        yMin=-10,
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        k=1)
        annotation (Placement(transformation(extent={{-60,20},{-40,40}})));
      Buildings.Controls.Continuous.LimPID conPID1(
        Ti=0.1,
        Td=0,
        yMax=10,
        yMin=0,
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        k=1)
        annotation (Placement(transformation(extent={{-60,60},{-40,80}})));
    equation
      connect(returnAir, bou.ports[1:1]) annotation (Line(points={{104,-60},{32,
              -60},{-40,-60}}, color={0,127,255}));
      connect(heatSupplyAir.ports[1:1], supplyAirHeat) annotation (Line(points=
              {{40,70},{104,70},{104,60}}, color={0,127,255}));
      connect(coolSupplyAir.ports[1:1], supplyAirCool) annotation (Line(points=
              {{40,30},{66,30},{66,14},{104,14}}, color={0,127,255}));
      connect(TcoolSetpoint, conPID.u_s) annotation (Line(points={{-120,30},{
              -91,30},{-62,30}}, color={0,0,127}));
      connect(Tmea, conPID.u_m) annotation (Line(points={{-120,-40},{-50,-40},{
              -50,18}}, color={0,0,127}));
      connect(TheatSetpoint, conPID1.u_s) annotation (Line(points={{-120,70},{
              -91,70},{-62,70}}, color={0,0,127}));
      connect(Tmea, conPID1.u_m) annotation (Line(points={{-120,-40},{-82,-40},
              {-82,50},{-50,50},{-50,58}}, color={0,0,127}));
      connect(conPID1.y, heatSupplyAir.m_flow_in) annotation (Line(points={{-39,
              70},{-6,70},{-6,78},{20,78}}, color={0,0,127}));
      connect(conPID.y, coolGain.u) annotation (Line(points={{-39,30},{-30.5,30},
              {-22,30}}, color={0,0,127}));
      connect(coolGain.y, coolSupplyAir.m_flow_in) annotation (Line(points={{1,
              30},{6,30},{6,38},{20,38}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end IdealAir_PI;

    model Control

      Modelica.Blocks.Math.Gain heatGain(k=1/sensitivityGainHeat)
        annotation (Placement(transformation(extent={{-120,120},{-100,140}})));
      Modelica.Blocks.Math.Gain coolAirGain(k=-designAirFlow)
        annotation (Placement(transformation(extent={{-116,20},{-96,40}})));
      Modelica.Blocks.Math.Feedback heatError
        annotation (Placement(transformation(extent={{-160,120},{-140,140}})));
      Modelica.Blocks.Math.Feedback coolError
        annotation (Placement(transformation(extent={{-180,20},{-160,40}})));
      Modelica.Blocks.Nonlinear.Limiter limiterAirCool(
        uMax=designAirFlow,
        uMin=minAirFlow,
        y(start=minAirFlow))
        annotation (Placement(transformation(extent={{-84,20},{-64,40}})));
      Modelica.Blocks.Math.Gain coolGain(k=1/sensitivityGainCool)
        annotation (Placement(transformation(extent={{-152,20},{-132,40}})));
      Modelica.Blocks.Nonlinear.Limiter limiterHeat(uMin=0, uMax=1)
        annotation (Placement(transformation(extent={{-60,110},{-40,130}})));
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Real sensitivityGainHeat = 1 "[K] Gain sensitivity on heating controller";
      parameter Real sensitivityGainCool = 0.3 "[K] Gain sensitivity on cooling controller";
      Modelica.Blocks.Interfaces.RealInput TcoolSet annotation (Placement(
            transformation(rotation=0, extent={{-210,70},{-190,90}})));
      Modelica.Blocks.Interfaces.RealInput Tmea annotation (Placement(
            transformation(rotation=0, extent={{-210,-22},{-190,-2}})));
      Modelica.Blocks.Interfaces.RealInput TheatSet annotation (Placement(
            transformation(rotation=0, extent={{-210,120},{-190,140}})));
      Modelica.Blocks.Interfaces.RealOutput fanSet(start=minAirFlow)
        annotation (Placement(transformation(rotation=0, extent={{10,-10},{30,
                10}})));
      Modelica.Blocks.Interfaces.RealOutput heaterSet annotation (Placement(
            transformation(rotation=0, extent={{10,110},{30,130}})));
      Modelica.Blocks.Interfaces.RealOutput coolSignal
                                                      annotation (Placement(
            transformation(rotation=0, extent={{10,70},{30,90}})));
      Modelica.Blocks.Math.Sign sign1
        annotation (Placement(transformation(extent={{-60,80},{-40,100}})));
      Buildings.Utilities.Math.SmoothMax smoothMax(deltaX=1)
        annotation (Placement(transformation(extent={{-20,70},{0,90}})));
      Modelica.Blocks.Sources.Constant zero(k=0)
        annotation (Placement(transformation(extent={{-60,50},{-40,70}})));
    equation
      connect(heatError.y,heatGain. u) annotation (Line(points={{-141,130},{-141,130},
              {-122,130}}, color={0,0,127}));
      connect(coolAirGain.y,limiterAirCool. u)
        annotation (Line(points={{-95,30},{-92,30},{-90,30},{-86,30}},
                                                     color={0,0,127}));
      connect(coolError.y,coolGain. u)
        annotation (Line(points={{-161,30},{-154,30}}, color={0,0,127}));
      connect(coolAirGain.u,coolGain. y)
        annotation (Line(points={{-118,30},{-131,30}}, color={0,0,127}));
      connect(TcoolSet, coolError.u1) annotation (Line(points={{-200,80},{-178,
              80},{-178,30}}, color={0,0,127}));
      connect(Tmea, coolError.u2) annotation (Line(points={{-200,-12},{-200,-12},
              {-170,-12},{-170,22}}, color={0,0,127}));
      connect(TheatSet, heatError.u1)
        annotation (Line(points={{-200,130},{-158,130}}, color={0,0,127}));
      connect(Tmea, heatError.u2) annotation (Line(points={{-200,-12},{-200,-12},
              {-170,-12},{-150,-12},{-150,122}}, color={0,0,127}));
      connect(heatGain.y, limiterHeat.u) annotation (Line(points={{-99,130},{
              -76,130},{-76,120},{-54,120},{-62,120}},
                                   color={0,0,127}));
      connect(sign1.y, smoothMax.u1) annotation (Line(points={{-39,90},{-26,90},
              {-26,86},{-22,86}}, color={0,0,127}));
      connect(coolSignal, smoothMax.y)
        annotation (Line(points={{20,80},{4,80},{1,80}}, color={0,0,127}));
      connect(zero.y, smoothMax.u2) annotation (Line(points={{-39,60},{-39,60},
              {-32,60},{-32,74},{-22,74}}, color={0,0,127}));
      connect(sign1.u, limiterAirCool.u) annotation (Line(points={{-62,90},{-90,
              90},{-90,30},{-86,30}}, color={0,0,127}));
      connect(limiterHeat.y, heaterSet) annotation (Line(points={{-39,120},{20,
              120},{20,120}}, color={0,0,127}));
      connect(limiterAirCool.y, fanSet) annotation (Line(points={{-63,30},{-44,
              30},{-44,0},{20,0}}, color={0,0,127}));
      annotation (Diagram(coordinateSystem(extent={{-190,-40},{10,160}})), Icon(
            coordinateSystem(extent={{-190,-40},{10,160}})));
    end Control;

    model Control_GPC36

      Modelica.Blocks.Math.Feedback heatError
        annotation (Placement(transformation(extent={{-160,120},{-140,140}})));
      Modelica.Blocks.Math.Feedback coolError
        annotation (Placement(transformation(extent={{-180,20},{-160,40}})));
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate maxAirFlowHeat "Maximum airflow rate of system during heating";
      parameter Real sensitivityGainHeat = 2 "[K] Gain sensitivity on heating controller";
      parameter Real sensitivityGainCool = 2 "[K] Gain sensitivity on cooling controller";
      Modelica.Blocks.Interfaces.RealInput TcoolSet annotation (Placement(
            transformation(rotation=0, extent={{-210,70},{-190,90}})));
      Modelica.Blocks.Interfaces.RealInput Tmea annotation (Placement(
            transformation(rotation=0, extent={{-210,-10},{-190,10}})));
      Modelica.Blocks.Interfaces.RealInput TheatSet annotation (Placement(
            transformation(rotation=0, extent={{-210,120},{-190,140}})));
      Modelica.Blocks.Interfaces.RealOutput fanSet(start=minAirFlow)
        annotation (Placement(transformation(rotation=0, extent={{10,-10},{30,
                10}})));
      Modelica.Blocks.Interfaces.RealOutput heatSAT annotation (Placement(
            transformation(rotation=0, extent={{10,110},{30,130}})));
      Buildings.Experimental.OpenBuildingControl.ASHRAE.G36.VAVSingleZoneTSupSet
        setPoiVAV(
        yCooMax=1,
        yMin=minAirFlow/designAirFlow,
        yHeaMax=maxAirFlowHeat/designAirFlow,
        TMax=318.15,
        TMin=285.15)
        annotation (Placement(transformation(extent={{-60,60},{-40,80}})));
      Modelica.Blocks.Math.Add add
        annotation (Placement(transformation(extent={{-176,76},{-156,96}})));
      Modelica.Blocks.Math.Division division
        annotation (Placement(transformation(extent={{-138,70},{-118,90}})));
      Modelica.Blocks.Sources.Constant const(k=2)
        annotation (Placement(transformation(extent={{-176,48},{-156,68}})));
      Modelica.Blocks.Math.Gain coolGain(k=-1/sensitivityGainCool)
        annotation (Placement(transformation(extent={{-140,20},{-120,40}})));
      Modelica.Blocks.Interfaces.RealOutput coolSAT annotation (Placement(
            transformation(rotation=0, extent={{10,70},{30,90}})));
      Modelica.Blocks.Interfaces.RealInput Tout annotation (Placement(
            transformation(rotation=0, extent={{-210,-50},{-190,-30}})));
      Modelica.Blocks.Math.Gain heatGain(k=1/sensitivityGainHeat)
        annotation (Placement(transformation(extent={{-128,120},{-108,140}})));
      Modelica.Blocks.Math.Max max
        annotation (Placement(transformation(extent={{-90,110},{-70,130}})));
      Modelica.Blocks.Sources.Constant zero(k=0)
        annotation (Placement(transformation(extent={{-140,-30},{-120,-10}})));
      Modelica.Blocks.Math.Max max1
        annotation (Placement(transformation(extent={{-100,14},{-80,34}})));
    equation
      connect(Tmea, coolError.u2) annotation (Line(points={{-200,0},{-200,0},{-170,0},
              {-170,22}},            color={0,0,127}));
      connect(TheatSet, heatError.u1)
        annotation (Line(points={{-200,130},{-158,130}}, color={0,0,127}));
      connect(Tmea, heatError.u2) annotation (Line(points={{-200,0},{-200,0},{-168,0},
              {-150,0},{-150,122}},              color={0,0,127}));
      connect(TheatSet, add.u1) annotation (Line(points={{-200,130},{-192,130},
              {-186,130},{-186,92},{-178,92}}, color={0,0,127}));
      connect(TcoolSet, add.u2) annotation (Line(points={{-200,80},{-186,80},{
              -178,80}}, color={0,0,127}));
      connect(add.y, division.u1) annotation (Line(points={{-155,86},{-147.5,86},
              {-140,86}}, color={0,0,127}));
      connect(const.y, division.u2) annotation (Line(points={{-155,58},{-144,58},
              {-144,74},{-140,74}}, color={0,0,127}));
      connect(coolError.y, coolGain.u) annotation (Line(points={{-161,30},{-152,
              30},{-142,30}}, color={0,0,127}));
      connect(division.y, setPoiVAV.TSetZon) annotation (Line(points={{-117,80},
              {-90,80},{-90,70},{-62,70}},   color={0,0,127}));
      connect(Tmea, setPoiVAV.TZon) annotation (Line(points={{-200,0},{-200,0},
              {-76,0},{-76,66},{-62,66}},        color={0,0,127}));
      connect(setPoiVAV.y, fanSet) annotation (Line(points={{-39,64},{-39,64},{
              -30,64},{-30,0},{20,0}}, color={0,0,127}));
      connect(setPoiVAV.TCoo, coolSAT) annotation (Line(points={{-39,70},{-10,
              70},{-10,80},{6,80},{20,80}},
                                     color={0,0,127}));
      connect(setPoiVAV.THea, heatSAT) annotation (Line(points={{-39,76},{-39,
              78},{-14,78},{-14,120},{-10,120},{-10,120},{20,120}},
                                                color={0,0,127}));
      connect(TcoolSet, coolError.u1) annotation (Line(points={{-200,80},{-186,
              80},{-186,30},{-178,30}}, color={0,0,127}));
      connect(Tout, setPoiVAV.TOut) annotation (Line(points={{-200,-40},{-200,
              -40},{-74,-40},{-74,62},{-62,62}},
                                           color={0,0,127}));
      connect(heatError.y, heatGain.u) annotation (Line(points={{-141,130},{-135.5,
              130},{-130,130}}, color={0,0,127}));
      connect(heatGain.y, max.u1) annotation (Line(points={{-107,130},{-100,130},{-100,
              126},{-92,126}}, color={0,0,127}));
      connect(max.y, setPoiVAV.uHea) annotation (Line(points={{-69,120},{-66,
              120},{-66,78},{-62,78}},
                             color={0,0,127}));
      connect(zero.y, max.u2) annotation (Line(points={{-119,-20},{-108,-20},{
              -108,114},{-92,114}},
                          color={0,0,127}));
      connect(coolGain.y, max1.u1) annotation (Line(points={{-119,30},{-110,30},
              {-102,30}},     color={0,0,127}));
      connect(zero.y, max1.u2) annotation (Line(points={{-119,-20},{-108,-20},{
              -108,18},{-102,18}},
                              color={0,0,127}));
      connect(max1.y, setPoiVAV.uCoo) annotation (Line(points={{-79,24},{-78,24},
              {-78,74},{-62,74}},
                             color={0,0,127}));
      annotation (Diagram(coordinateSystem(extent={{-190,-40},{10,160}})), Icon(
            coordinateSystem(extent={{-190,-40},{10,160}})));
    end Control_GPC36;

    model VAV_SingleZone "Single zone VAV HVAC system"
      replaceable package Medium =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component"
          annotation (choicesAllMatching = true);
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Modelica.SIunits.Temperature supplyAirTempSet "Cooling supply air temperature setpoint";
      parameter Modelica.SIunits.Power designHeatingCapacity "Design heating capacity of cooling coil";
      parameter Modelica.SIunits.Power designCoolingCapacity "Design heating capacity of cooling coil";
      parameter Real sensitivityGainHeat = 1 "[K] Gain sensitivity on heating controller";
      parameter Real sensitivityGainCool = 0.3 "[K] Gain sensitivity on cooling controller";
      Modelica.Blocks.Interfaces.RealInput Tmea
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{-20,-20},{20,20}},
            rotation=0,
            origin={-220,0})));
      Buildings.Fluid.Sources.MassFlowSource_T     supplyFan(redeclare package
          Medium = Medium,
        use_m_flow_in=true,
        use_T_in=true,
        nPorts=1)           "Supply air fan"
        annotation (Placement(transformation(extent={{-20,38},{0,58}})));
      Modelica.Fluid.Interfaces.FluidPorts_b supplyAir(redeclare package Medium =
            Medium) "Supply air port"
        annotation (Placement(transformation(extent={{190,12},{210,92}})));
      Modelica.Blocks.Interfaces.RealInput TheatSetpoint
        "Zone heating setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,130})));
      Modelica.Blocks.Interfaces.RealInput TcoolSetpoint
        "Zone cooling setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,78})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u coolCoil(
        redeclare package Medium = Medium,
        Q_flow_nominal=designCoolingCapacity,
        m_flow_nominal=designAirFlow,
        dp_nominal=0,
        u(start=0),
        tau=90)                       "DX air cooling coil"
        annotation (Placement(transformation(extent={{36,38},{56,58}})));
      Buildings.Fluid.Sensors.Temperature supplyAirTemp(redeclare package
          Medium =
            Medium)
        "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{110,62},{130,82}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u heatCoil(
        m_flow_nominal=designAirFlow,
        redeclare package Medium = Medium,
        Q_flow_nominal=designHeatingCapacity,
        dp_nominal=0,
        u(start=0),
        tau=90)                               "Air heating coil"
        annotation (Placement(transformation(extent={{76,38},{96,58}})));
      Modelica.Blocks.Continuous.LimPID P(
        yMin=-1,
        yMax=0,
        Td=0.1,
        Ti=0.08,
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        k=1.5e-1)
        annotation (Placement(transformation(extent={{148,10},{128,-10}})));
      Modelica.Blocks.Sources.Constant supplyAirTempSetConst(k=supplyAirTempSet)
        annotation (Placement(transformation(extent={{180,-10},{160,10}})));
      Control control(
        minAirFlow=minAirFlow,
        designAirFlow=designAirFlow,
        sensitivityGainHeat=sensitivityGainHeat,
        sensitivityGainCool=sensitivityGainCool)
        annotation (Placement(transformation(extent={{-102,-12},{-82,8}})));
      Modelica.Blocks.Math.Product product annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=90,
            origin={20,18})));
    equation
      connect(supplyAirTemp.port, supplyAir) annotation (Line(points={{120,62},{120,
              48},{200,48},{200,52}}, color={0,127,255}));
      connect(coolCoil.port_b, heatCoil.port_a)
        annotation (Line(points={{56,48},{76,48}}, color={0,127,255}));
      connect(heatCoil.port_b, supplyAir)
        annotation (Line(points={{96,48},{200,48},{200,52}}, color={0,127,255}));
      connect(supplyAirTempSetConst.y, P.u_s)
        annotation (Line(points={{159,0},{148,0},{150,0}}, color={0,0,127}));
      connect(supplyAirTemp.T, P.u_m)
        annotation (Line(points={{127,72},{138,72},{138,12}}, color={0,0,127}));
      connect(supplyFan.ports[1], coolCoil.port_a)
        annotation (Line(points={{0,48},{36,48}}, color={0,127,255}));
      connect(P.y, product.u2)
        annotation (Line(points={{127,0},{84,0},{26,0},{26,6}}, color={0,0,127}));
      connect(TheatSetpoint, control.TheatSet) annotation (Line(points={{-220,
              130},{-162,130},{-162,5},{-103,5}}, color={0,0,127}));
      connect(TcoolSetpoint, control.TcoolSet) annotation (Line(points={{-220,78},
              {-198,78},{-176,78},{-176,0},{-103,0}},       color={0,0,127}));
      connect(control.Tmea, Tmea) annotation (Line(points={{-103,-9.2},{-164,
              -9.2},{-190,-9.2},{-190,0},{-220,0}}, color={0,0,127}));
      connect(control.coolSignal, product.u1)
        annotation (Line(points={{-81,0},{14,0},{14,6}}, color={0,0,127}));
      connect(control.heaterSet, heatCoil.u) annotation (Line(points={{-81,4},{
              -62,4},{-62,104},{64,104},{64,54},{74,54}}, color={0,0,127}));
      connect(control.fanSet, supplyFan.m_flow_in) annotation (Line(points={{
              -81,-8},{-68,-8},{-50,-8},{-50,56},{-20,56}}, color={0,0,127}));
      connect(product.y, coolCoil.u) annotation (Line(points={{20,29},{20,29},{
              20,54},{34,54}}, color={0,0,127}));
      connect(Tmea, supplyFan.T_in) annotation (Line(points={{-220,0},{-206,0},
              {-190,0},{-190,52},{-22,52}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},
                {200,160}})),                                        Diagram(
            coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},{200,160}})),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone;

    model VAV_SingleZone_dxCoil_fan
      "Single zone VAV HVAC system with dx coil and fan"
      replaceable package Medium =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component"
          annotation (choicesAllMatching = true);
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Modelica.SIunits.Temperature supplyAirTempSet "Cooling supply air temperature setpoint";
      parameter Modelica.SIunits.Power designHeatingCapacity "Design heating capacity of heating coil";
      parameter Real designHeatingEfficiency "Design heating efficiency of the heating coil";
      parameter Modelica.SIunits.Power designCoolingCapacity "Design heating capacity of cooling coil";
      parameter Real designCoolingCOP "Design cooling COP of the cooling coil";
      parameter Real sensitivityGainHeat = 2 "[K] Gain sensitivity on heating controller";
      parameter Real sensitivityGainCool = 2 "[K] Gain sensitivity on cooling controller";
      Modelica.Blocks.Interfaces.RealInput Tmea
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{-20,-20},{20,20}},
            rotation=0,
            origin={-220,0})));
      Modelica.Fluid.Interfaces.FluidPorts_b supplyAir(redeclare package Medium =
            Medium) "Supply air port"
        annotation (Placement(transformation(extent={{190,12},{210,92}})));
      Modelica.Fluid.Interfaces.FluidPorts_b returnAir[1](redeclare package Medium =
                   Medium)                               "Return air"
        annotation (Placement(transformation(extent={{190,-100},{210,-20}})));
      Modelica.Blocks.Interfaces.RealInput TheatSetpoint
        "Zone heating setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,130})));
      Modelica.Blocks.Interfaces.RealInput TcoolSetpoint
        "Zone cooling setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,78})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          supplyAirTemp(redeclare package Medium =
            Medium, m_flow_nominal=designAirFlow,
        tau=30)
        "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{110,38},{130,58}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u heatCoil(
        m_flow_nominal=designAirFlow,
        redeclare package Medium = Medium,
        Q_flow_nominal=designHeatingCapacity,
        u(start=0),
        dp_nominal=0,
        tau=90)                               "Air heating coil"
        annotation (Placement(transformation(extent={{76,38},{96,58}})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation (Placement(
            transformation(extent={{-190,148},{-150,188}}), iconTransformation(
              extent={{-180,160},{-160,180}})));
      Buildings.Fluid.HeatExchangers.DXCoils.VariableSpeed mulStaDX(
        datCoi=dxCoilPerformance,
        redeclare package Medium = Medium,
        minSpeRat=dxCoilPerformance.minSpeRat,
        dp_nominal=0,
        tau=90)
        annotation (Placement(transformation(extent={{36,38},{56,58}})));
      parameter Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.DXCoil
        dxCoilPerformance(nSta=1, sta={
            Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.Stage(
            spe=1,
            nomVal=
              Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.NominalValues(
              Q_flow_nominal=-designCoolingCapacity,
              COP_nominal=designCoolingCOP,
              SHR_nominal=0.8,
              m_flow_nominal=0.75),
            perCur=dxCoilPerformanceCurve)},
        minSpeRat=0)
        annotation (Placement(transformation(extent={{120,142},{140,162}})));
      Buildings.Fluid.Movers.FlowControlled_m_flow supplyFan(
        redeclare package Medium = Medium,
        m_flow_nominal=designAirFlow,
        energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
        nominalValuesDefineDefaultPressureCurve=true,
        dp_nominal=500,
        per(use_powerCharacteristic=false))
        annotation (Placement(transformation(extent={{-40,38},{-20,58}})));
      Modelica.Blocks.Math.Product product annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=90,
            origin={28,10})));
      Modelica.Blocks.Continuous.LimPID P(
        yMin=-1,
        yMax=0,
        Td=0.1,
        Ti=0.08,
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        k=1.5e-1)
        annotation (Placement(transformation(extent={{158,2},{138,-18}})));
      Modelica.Blocks.Sources.Constant supplyAirTempSetConst(k=supplyAirTempSet)
        annotation (Placement(transformation(extent={{190,-18},{170,2}})));
      Control control(designAirFlow=designAirFlow, minAirFlow=minAirFlow,
        sensitivityGainHeat=sensitivityGainHeat,
        sensitivityGainCool=sensitivityGainCool)
        annotation (Placement(transformation(extent={{-140,0},{-120,20}})));
      Modelica.Blocks.Math.Gain gain(k=-1) annotation (Placement(transformation(
            extent={{4,-4},{-4,4}},
            rotation=-90,
            origin={28,36})));
      Buildings.Fluid.FixedResistances.PressureDrop totalRes(
        m_flow_nominal=designAirFlow,
        dp_nominal=500,
        redeclare package Medium = Medium)
        annotation (Placement(transformation(extent={{-10,38},{10,58}})));
      Modelica.Blocks.Interfaces.RealOutput fanPower
        "Electrical power consumed by the supply fan"
        annotation (Placement(transformation(extent={{200,150},{220,170}})));
      Modelica.Blocks.Interfaces.RealOutput heatCoilPower
        "Electrical power consumed by the heating coil"
        annotation (Placement(transformation(extent={{200,130},{220,150}})));
      Modelica.Blocks.Interfaces.RealOutput coolCoilPower
        "Electrical power consumed by DX cooling coil compressor"
        annotation (Placement(transformation(extent={{200,110},{220,130}})));
    equation

      connect(heatCoil.port_b, supplyAirTemp.port_a) annotation (Line(points={{
              96,48},{104,48},{110,48}}, color={0,127,255}));
      connect(supplyAirTemp.port_b, supplyAir) annotation (Line(points={{130,48},
              {200,48},{200,52}}, color={0,127,255}));
      connect(mulStaDX.port_b, heatCoil.port_a)
        annotation (Line(points={{56,48},{56,48},{76,48}}, color={0,127,255}));
      connect(weaBus.TDryBul, mulStaDX.TConIn) annotation (Line(
          points={{-170,168},{-170,144},{24,144},{24,51},{35,51}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));
      connect(returnAir[1], supplyFan.port_a) annotation (Line(points={{200,-60},{70,
              -60},{-52,-60},{-52,48},{-40,48}}, color={0,127,255}));
      connect(supplyAirTempSetConst.y, P.u_s)
        annotation (Line(points={{169,-8},{160,-8}},          color={0,0,127}));
      connect(supplyAirTemp.T, P.u_m) annotation (Line(points={{120,59},{120,74},{148,
              74},{148,4}}, color={0,0,127}));
      connect(P.y, product.u2) annotation (Line(points={{137,-8},{86,-8},{34,-8},{34,
              -2}}, color={0,0,127}));
      connect(control.fanSet, supplyFan.m_flow_in) annotation (Line(points={{-119,4},
              {-98,4},{-98,80},{-30.2,80},{-30.2,60}}, color={0,0,127}));
      connect(control.coolSignal, product.u1) annotation (Line(points={{-119,12},{-74,
              12},{-32,12},{-32,-8},{22,-8},{22,-2}}, color={0,0,127}));
      connect(control.heaterSet, heatCoil.u) annotation (Line(points={{-119,16},{-112,
              16},{-112,88},{-112,90},{66,90},{66,54},{74,54}}, color={0,0,127}));
      connect(TheatSetpoint, control.TheatSet) annotation (Line(points={{-220,130},{
              -160,130},{-160,17},{-141,17}}, color={0,0,127}));
      connect(TcoolSetpoint, control.TcoolSet) annotation (Line(points={{-220,78},{-202,
              78},{-178,78},{-178,12},{-141,12}}, color={0,0,127}));
      connect(Tmea, control.Tmea) annotation (Line(points={{-220,0},{-181,0},{-181,2.8},
              {-141,2.8}}, color={0,0,127}));
      connect(product.y, gain.u)
        annotation (Line(points={{28,21},{28,21},{28,31.2}}, color={0,0,127}));
      connect(gain.y, mulStaDX.speRat)
        annotation (Line(points={{28,40.4},{28,56},{35,56}}, color={0,0,127}));
      connect(supplyFan.port_b, totalRes.port_a)
        annotation (Line(points={{-20,48},{-10,48}}, color={0,127,255}));
      connect(totalRes.port_b, mulStaDX.port_a)
        annotation (Line(points={{10,48},{24,48},{36,48}}, color={0,127,255}));
      connect(supplyFan.P, fanPower) annotation (Line(points={{-19,56},{0,56},{
              0,160},{210,160}}, color={0,0,127}));
      connect(heatCoil.Q_flow, heatCoilPower) annotation (Line(points={{97,54},
              {104,54},{104,130},{174,130},{174,140},{210,140}}, color={0,0,127}));
      connect(mulStaDX.P, coolCoilPower) annotation (Line(points={{57,57},{62,
              57},{62,120},{210,120}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},
                {200,160}})),                                        Diagram(
            coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},{200,160}})),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_dxCoil_fan;

    model VAV_SingleZone_dxCoilSingle_fan
      "Single zone VAV HVAC system with single speed dx coil and fan"
      replaceable package Medium =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component"
          annotation (choicesAllMatching = true);
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Modelica.SIunits.Temperature supplyAirTempSet "Cooling supply air temperature setpoint";
      parameter Modelica.SIunits.Power designHeatingCapacity "Design heating capacity of heating coil";
      parameter Real designHeatingEfficiency "Design heating efficiency of the heating coil";
      parameter Modelica.SIunits.Power designCoolingCapacity "Design heating capacity of cooling coil";
      parameter Real designCoolingCOP "Design cooling COP of the cooling coil";
      parameter Real sensitivityGainHeat = 2 "[K] Gain sensitivity on heating controller";
      parameter Real sensitivityGainCool = 2 "[K] Gain sensitivity on cooling controller";
      Modelica.Blocks.Interfaces.RealInput Tmea
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{-20,-20},{20,20}},
            rotation=0,
            origin={-220,0})));
      Modelica.Fluid.Interfaces.FluidPorts_b supplyAir(redeclare package Medium =
            Medium) "Supply air port"
        annotation (Placement(transformation(extent={{190,12},{210,92}})));
      Modelica.Fluid.Interfaces.FluidPorts_b returnAir[1](redeclare package
          Medium = Medium)                               "Return air"
        annotation (Placement(transformation(extent={{190,-100},{210,-20}})));
      Modelica.Blocks.Interfaces.RealInput TheatSetpoint
        "Zone heating setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,130})));
      Modelica.Blocks.Interfaces.RealInput TcoolSetpoint
        "Zone cooling setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,78})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          supplyAirTemp(redeclare package
          Medium =
            Medium, m_flow_nominal=designAirFlow,
        tau=30)
        "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{110,38},{130,58}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u heatCoil(
        m_flow_nominal=designAirFlow,
        redeclare package Medium = Medium,
        Q_flow_nominal=designHeatingCapacity,
        u(start=0),
        dp_nominal=0,
        tau=90)                               "Air heating coil"
        annotation (Placement(transformation(extent={{76,38},{96,58}})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation (Placement(
            transformation(extent={{-190,148},{-150,188}}), iconTransformation(
              extent={{-180,160},{-160,180}})));
      Buildings.Fluid.HeatExchangers.DXCoils.SingleSpeed dxCoilSingle(
        datCoi=dxCoilPerformance,
        redeclare package Medium = Medium,
        dp_nominal=0,
        tau=90) annotation (Placement(transformation(extent={{36,38},{56,58}})));
      parameter Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.DXCoil
        dxCoilPerformance(nSta=1, sta={
            Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.Stage(
            spe=1,
            nomVal=
              Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.NominalValues(
              Q_flow_nominal=-designCoolingCapacity,
              COP_nominal=designCoolingCOP,
              SHR_nominal=0.8,
              m_flow_nominal=0.75),
            perCur=dxCoilPerformanceCurve)},
        minSpeRat=0)
        annotation (Placement(transformation(extent={{120,142},{140,162}})));
      Buildings.Fluid.Movers.FlowControlled_m_flow supplyFan(
        redeclare package Medium = Medium,
        m_flow_nominal=designAirFlow,
        energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
        nominalValuesDefineDefaultPressureCurve=true,
        dp_nominal=875,
        per(use_powerCharacteristic=false))
        annotation (Placement(transformation(extent={{-40,38},{-20,58}})));
      Modelica.Blocks.Sources.Constant supplyAirTempSetConst(k=supplyAirTempSet)
        annotation (Placement(transformation(extent={{190,-18},{170,2}})));
      Control control(designAirFlow=designAirFlow, minAirFlow=minAirFlow,
        sensitivityGainHeat=sensitivityGainHeat,
        sensitivityGainCool=sensitivityGainCool)
        annotation (Placement(transformation(extent={{-140,0},{-120,20}})));
      Buildings.Fluid.FixedResistances.PressureDrop totalRes(
        m_flow_nominal=designAirFlow,
        dp_nominal=500,
        redeclare package Medium = Medium)
        annotation (Placement(transformation(extent={{-10,38},{10,58}})));
      Modelica.Blocks.Interfaces.RealOutput fanPower
        "Electrical power consumed by the supply fan"
        annotation (Placement(transformation(extent={{200,150},{220,170}})));
      Modelica.Blocks.Interfaces.RealOutput heatCoilPower
        "Electrical power consumed by the heating coil"
        annotation (Placement(transformation(extent={{200,130},{220,150}})));
      Modelica.Blocks.Interfaces.RealOutput coolCoilPower
        "Electrical power consumed by DX cooling coil compressor"
        annotation (Placement(transformation(extent={{200,110},{220,130}})));
      Modelica.Blocks.Logical.OnOffController onOffController(bandwidth=3)
        annotation (Placement(transformation(extent={{140,-20},{120,0}})));
      Modelica.Blocks.Logical.Not not1
        annotation (Placement(transformation(extent={{100,-20},{80,0}})));
      Modelica.Blocks.Logical.And and1
        annotation (Placement(transformation(extent={{0,0},{20,20}})));
      Modelica.Blocks.Logical.GreaterThreshold greaterThreshold(threshold=0.5)
        annotation (Placement(transformation(extent={{-40,0},{-20,20}})));
      Modelica.Blocks.Math.Gain eff(k=1/designHeatingEfficiency)
        annotation (Placement(transformation(extent={{122,90},{142,110}})));
    equation

      connect(heatCoil.port_b, supplyAirTemp.port_a) annotation (Line(points={{
              96,48},{104,48},{110,48}}, color={0,127,255}));
      connect(supplyAirTemp.port_b, supplyAir) annotation (Line(points={{130,48},
              {200,48},{200,52}}, color={0,127,255}));
      connect(dxCoilSingle.port_b, heatCoil.port_a)
        annotation (Line(points={{56,48},{56,48},{76,48}}, color={0,127,255}));
      connect(weaBus.TDryBul, dxCoilSingle.TConIn) annotation (Line(
          points={{-170,168},{-170,144},{24,144},{24,51},{35,51}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));
      connect(returnAir[1], supplyFan.port_a) annotation (Line(points={{200,-60},{70,
              -60},{-52,-60},{-52,48},{-40,48}}, color={0,127,255}));
      connect(control.fanSet, supplyFan.m_flow_in) annotation (Line(points={{-119,4},
              {-98,4},{-98,80},{-30.2,80},{-30.2,60}}, color={0,0,127}));
      connect(control.heaterSet, heatCoil.u) annotation (Line(points={{-119,16},{-112,
              16},{-112,88},{-112,90},{66,90},{66,54},{74,54}}, color={0,0,127}));
      connect(TheatSetpoint, control.TheatSet) annotation (Line(points={{-220,130},{
              -160,130},{-160,17},{-141,17}}, color={0,0,127}));
      connect(TcoolSetpoint, control.TcoolSet) annotation (Line(points={{-220,78},{-202,
              78},{-178,78},{-178,12},{-141,12}}, color={0,0,127}));
      connect(Tmea, control.Tmea) annotation (Line(points={{-220,0},{-181,0},{-181,2.8},
              {-141,2.8}}, color={0,0,127}));
      connect(supplyFan.port_b, totalRes.port_a)
        annotation (Line(points={{-20,48},{-10,48}}, color={0,127,255}));
      connect(totalRes.port_b, dxCoilSingle.port_a)
        annotation (Line(points={{10,48},{24,48},{36,48}}, color={0,127,255}));
      connect(supplyFan.P, fanPower) annotation (Line(points={{-19,56},{0,56},{
              0,160},{210,160}}, color={0,0,127}));
      connect(dxCoilSingle.P, coolCoilPower) annotation (Line(points={{57,57},{
              62,57},{62,120},{210,120}}, color={0,0,127}));
      connect(supplyAirTempSetConst.y, onOffController.reference) annotation (
          Line(points={{169,-8},{152,-8},{152,-4},{142,-4}}, color={0,0,127}));
      connect(supplyAirTemp.T, onOffController.u) annotation (Line(points={{120,
              59},{120,72},{152,72},{152,-16},{142,-16}}, color={0,0,127}));
      connect(onOffController.y, not1.u)
        annotation (Line(points={{119,-10},{102,-10}}, color={255,0,255}));
      connect(not1.y, and1.u2) annotation (Line(points={{79,-10},{32,-10},{-16,
              -10},{-16,2},{-2,2}}, color={255,0,255}));
      connect(control.coolSignal, greaterThreshold.u) annotation (Line(points={
              {-119,12},{-100,12},{-100,10},{-42,10}}, color={0,0,127}));
      connect(greaterThreshold.y, and1.u1) annotation (Line(points={{-19,10},{
              -19,10},{-2,10}}, color={255,0,255}));
      connect(and1.y, dxCoilSingle.on) annotation (Line(points={{21,10},{28,10},
              {28,56},{35,56}}, color={255,0,255}));
      connect(heatCoil.Q_flow, eff.u) annotation (Line(points={{97,54},{106,54},
              {106,100},{120,100}}, color={0,0,127}));
      connect(eff.y, heatCoilPower) annotation (Line(points={{143,100},{160,100},
              {160,140},{210,140}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},
                {200,160}})),                                        Diagram(
            coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},{200,160}})),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_dxCoilSingle_fan;

    model VAV_SingleZone_uCoils_fan_mix
      "Single zone VAV HVAC system with dx coil, fan, and mixing box"
      replaceable package Medium =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component"
          annotation (choicesAllMatching = true);
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minOAFlow "Minimum outside airflow";
      parameter Modelica.SIunits.Temperature supplyAirTempSet "Cooling supply air temperature setpoint";
      parameter Modelica.SIunits.Power designHeatingCapacity "Design heating capacity of heating coil";
      parameter Real designHeatingEfficiency "Design heating efficiency of the heating coil";
      parameter Modelica.SIunits.Power designCoolingCapacity "Design heating capacity of cooling coil";
      parameter Real designCoolingCOP "Design cooling COP of the cooling coil";
      parameter Real sensitivityGainHeat = 2 "[K] Gain sensitivity on heating controller";
      parameter Real sensitivityGainCool = 2 "[K] Gain sensitivity on cooling controller";
      Modelica.Blocks.Interfaces.RealInput Tmea
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{-20,-20},{20,20}},
            rotation=0,
            origin={-220,0})));
      Modelica.Fluid.Interfaces.FluidPorts_b supplyAir(redeclare package Medium =
            Medium) "Supply air port"
        annotation (Placement(transformation(extent={{190,12},{210,92}})));
      Modelica.Fluid.Interfaces.FluidPorts_b returnAir[1](redeclare package
          Medium = Medium)                               "Return air"
        annotation (Placement(transformation(extent={{190,-100},{210,-20}})));
      Modelica.Blocks.Interfaces.RealInput TheatSetpoint
        "Zone heating setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,130})));
      Modelica.Blocks.Interfaces.RealInput TcoolSetpoint
        "Zone cooling setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,78})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          supplyAirTemp(redeclare package
          Medium =
            Medium, m_flow_nominal=designAirFlow) "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{122,38},{142,58}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u heatCoil(
        m_flow_nominal=designAirFlow,
        redeclare package Medium = Medium,
        Q_flow_nominal=designHeatingCapacity,
        u(start=0),
        dp_nominal=0) "Air heating coil"
        annotation (Placement(transformation(extent={{40,38},{60,58}})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation (Placement(
            transformation(extent={{-190,148},{-150,188}}), iconTransformation(
              extent={{-180,160},{-160,180}})));
      Buildings.Fluid.Movers.FlowControlled_m_flow supplyFan(
        redeclare package Medium = Medium,
        m_flow_nominal=designAirFlow,
        energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
        nominalValuesDefineDefaultPressureCurve=true,
        dp_nominal=500,
        per(use_powerCharacteristic=false))
        annotation (Placement(transformation(extent={{-20,38},{0,58}})));
      Buildings.Fluid.FixedResistances.PressureDrop totalRes(
        m_flow_nominal=designAirFlow,
        dp_nominal=500,
        redeclare package Medium = Medium)
        annotation (Placement(transformation(extent={{10,38},{30,58}})));
      Buildings.Fluid.Sources.Outside out(          redeclare package Medium =
            Medium, nPorts=2)
        annotation (Placement(transformation(extent={{-140,36},{-120,56}})));
      Modelica.Blocks.Sources.Constant constFlow(k=minOAFlow)
        annotation (Placement(transformation(extent={{-140,-30},{-120,-10}})));
      Buildings.Fluid.Sensors.MassFlowRate exhaustAirFlow(redeclare package
          Medium =
            Medium)
        annotation (Placement(transformation(extent={{-30,-70},{-10,-50}})));
      Buildings.Fluid.Sensors.MassFlowRate oaAirFlow(redeclare package Medium =
            Medium)
        annotation (Placement(transformation(extent={{-90,38},{-70,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort mixedAirTemp(redeclare package
          Medium = Medium, m_flow_nominal=designAirFlow)
        "Mixed air temperature sensor"
        annotation (Placement(transformation(extent={{-50,38},{-30,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort returnAirTemp(redeclare
          package Medium =
                   Medium, m_flow_nominal=designAirFlow)
        "Mixed air temperature sensor"
        annotation (Placement(transformation(extent={{70,-70},{90,-50}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u coolCoil(
        m_flow_nominal=designAirFlow,
        redeclare package Medium = Medium,
        u(start=0),
        dp_nominal=0,
        Q_flow_nominal=designCoolingCapacity) "Air cooling coil"
        annotation (Placement(transformation(extent={{80,38},{100,58}})));
      Buildings.Fluid.Movers.FlowControlled_m_flow reliefFan(
        redeclare package Medium = Medium,
        energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
        nominalValuesDefineDefaultPressureCurve=true,
        dp_nominal=500,
        per(use_powerCharacteristic=false),
        m_flow_nominal=minOAFlow)
        annotation (Placement(transformation(extent={{-72,-70},{-92,-50}})));
      Buildings.Fluid.Sensors.MassFlowRate returnAirFlow(redeclare package
          Medium =
            Medium) annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=90,
            origin={-60,-10})));
      Control control(
        minAirFlow=minAirFlow,
        designAirFlow=designAirFlow,
        sensitivityGainHeat=sensitivityGainHeat,
        sensitivityGainCool=sensitivityGainCool)
        annotation (Placement(transformation(extent={{-140,0},{-120,20}})));
      Modelica.Blocks.Sources.Constant supplyAirTempSetConst(k=supplyAirTempSet)
        annotation (Placement(transformation(extent={{192,-16},{172,4}})));
      Buildings.Controls.Continuous.LimPID conP(
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        yMax=0,
        yMin=-1,
        k=1.5e-1)
        annotation (Placement(transformation(extent={{160,4},{140,-16}})));
      Modelica.Blocks.Math.Product product annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=90,
            origin={74,10})));
    equation

      connect(supplyAirTemp.port_b, supplyAir) annotation (Line(points={{142,48},{200,
              48},{200,52}},      color={0,127,255}));
      connect(weaBus, out.weaBus) annotation (Line(
          points={{-170,168},{-170,144},{-170,46.2},{-140,46.2}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));
      connect(oaAirFlow.port_a, out.ports[1])
        annotation (Line(points={{-90,48},{-106,48},{-106,48},{-120,48}},
                                                      color={0,127,255}));
      connect(exhaustAirFlow.port_b, returnAirTemp.port_a)
        annotation (Line(points={{-10,-60},{30,-60},{70,-60}}, color={0,127,255}));
      connect(returnAirTemp.port_b, returnAir[1]) annotation (Line(points={{90,-60},
              {200,-60},{200,-60}}, color={0,127,255}));
      connect(totalRes.port_b, heatCoil.port_a)
        annotation (Line(points={{30,48},{40,48}}, color={0,127,255}));
      connect(mixedAirTemp.port_b, supplyFan.port_a)
        annotation (Line(points={{-30,48},{-25,48},{-20,48}}, color={0,127,255}));
      connect(supplyFan.port_b, totalRes.port_a)
        annotation (Line(points={{0,48},{6,48},{10,48}}, color={0,127,255}));
      connect(heatCoil.port_b, coolCoil.port_a)
        annotation (Line(points={{60,48},{70,48},{80,48}}, color={0,127,255}));
      connect(coolCoil.port_b, supplyAirTemp.port_a)
        annotation (Line(points={{100,48},{111,48},{122,48}}, color={0,127,255}));
      connect(constFlow.y, reliefFan.m_flow_in) annotation (Line(points={{-119,-20},
              {-100,-20},{-81.8,-20},{-81.8,-48}}, color={0,0,127}));
      connect(reliefFan.port_b, out.ports[2]) annotation (Line(points={{-92,-60},{-98,
              -60},{-100,-60},{-100,44},{-116,44},{-120,44}}, color={0,127,255}));
      connect(returnAirFlow.port_a, exhaustAirFlow.port_a) annotation (Line(points={
              {-60,-20},{-60,-20},{-60,-60},{-30,-60}}, color={0,127,255}));
      connect(reliefFan.port_a, exhaustAirFlow.port_a)
        annotation (Line(points={{-72,-60},{-30,-60}}, color={0,127,255}));
      connect(control.fanSet, supplyFan.m_flow_in) annotation (Line(points={{-119,4},
              {-110,4},{-110,80},{-10.2,80},{-10.2,60}}, color={0,0,127}));
      connect(control.heaterSet, heatCoil.u) annotation (Line(points={{-119,16},{-112,
              16},{-112,82},{32,82},{32,54},{38,54}}, color={0,0,127}));
      connect(TheatSetpoint, control.TheatSet) annotation (Line(points={{-220,130},{
              -174,130},{-174,17},{-141,17}}, color={0,0,127}));
      connect(TcoolSetpoint, control.TcoolSet) annotation (Line(points={{-220,78},{-202,
              78},{-202,76},{-182,76},{-182,12},{-141,12}}, color={0,0,127}));
      connect(Tmea, control.Tmea) annotation (Line(points={{-220,0},{-182,0},{-182,2.8},
              {-141,2.8}}, color={0,0,127}));
      connect(oaAirFlow.port_b, mixedAirTemp.port_a) annotation (Line(points={{
              -70,48},{-60,48},{-50,48}}, color={0,127,255}));
      connect(returnAirFlow.port_b, mixedAirTemp.port_a) annotation (Line(
            points={{-60,0},{-60,48},{-50,48}}, color={0,127,255}));
      connect(supplyAirTempSetConst.y, conP.u_s) annotation (Line(points={{171,
              -6},{164,-6},{162,-6}}, color={0,0,127}));
      connect(supplyAirTemp.T, conP.u_m) annotation (Line(points={{132,59},{132,
              72},{150,72},{150,16},{150,6}}, color={0,0,127}));
      connect(conP.y, product.u2)
        annotation (Line(points={{139,-6},{80,-6},{80,-2}}, color={0,0,127}));
      connect(control.coolSignal, product.u1) annotation (Line(points={{-119,12},
              {32,12},{32,-6},{68,-6},{68,-2}}, color={0,0,127}));
      connect(product.y, coolCoil.u) annotation (Line(points={{74,21},{74,21},{
              74,54},{78,54}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},
                {200,160}})),                                        Diagram(
            coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},{200,160}})),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_uCoils_fan_mix;

    model VAV_SingleZone_GPC36
      "Single zone VAV HVAC system with GPC36 logic written in CDL"
      replaceable package Medium =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component"
          annotation (choicesAllMatching = true);
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate maxAirFlowHeat "Maximum airflow rate of system during heating";
      parameter Modelica.SIunits.Temperature supplyAirTempSet "Cooling supply air temperature setpoint";
      parameter Modelica.SIunits.Power designHeatingCapacity "Design heating capacity of heating coil";
      parameter Real designHeatingEfficiency "Design heating efficiency of the heating coil";
      parameter Modelica.SIunits.Power designCoolingCapacity "Design heating capacity of cooling coil";
      parameter Real designCoolingCOP "Design cooling COP of the cooling coil";
      parameter Real sensitivityGainHeat = 2 "[K] Gain sensitivity on heating controller";
      parameter Real sensitivityGainCool = 2 "[K] Gain sensitivity on cooling controller";
      Modelica.Blocks.Interfaces.RealInput Tmea
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{-20,-20},{20,20}},
            rotation=0,
            origin={-220,0})));
      Buildings.Fluid.Sources.MassFlowSource_T     supplyFan(redeclare package
          Medium = Medium,
        use_m_flow_in=true,
        use_T_in=true,
        nPorts=1)           "Supply air fan"
        annotation (Placement(transformation(extent={{-20,38},{0,58}})));
      Modelica.Fluid.Interfaces.FluidPorts_b supplyAir(redeclare package Medium =
            Medium) "Supply air port"
        annotation (Placement(transformation(extent={{190,12},{210,92}})));
      Modelica.Blocks.Interfaces.RealInput TheatSetpoint
        "Zone heating setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,130})));
      Modelica.Blocks.Interfaces.RealInput TcoolSetpoint
        "Zone cooling setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,78})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_T coolCoil(
        redeclare package Medium = Medium,
        m_flow_nominal=designAirFlow,
        dp_nominal=0,
        Q_flow_maxHeat=0,
        Q_flow_maxCool=-designCoolingCapacity)
                                      "DX air cooling coil"
        annotation (Placement(transformation(extent={{36,38},{56,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          supplyAirTemp(redeclare package
          Medium =
            Medium, m_flow_nominal=designAirFlow)
        "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{110,38},{130,58}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_T heatCoil(
        m_flow_nominal=designAirFlow,
        redeclare package Medium = Medium,
        dp_nominal=0,
        Q_flow_maxCool=0,
        Q_flow_maxHeat=designHeatingCapacity) "Air heating coil"
        annotation (Placement(transformation(extent={{76,38},{96,58}})));
      Control_GPC36 control_GPC36(
        designAirFlow=designAirFlow,
        minAirFlow=minAirFlow,
        maxAirFlowHeat=maxAirFlowHeat,
        sensitivityGainHeat=sensitivityGainHeat,
        sensitivityGainCool=sensitivityGainCool)
        annotation (Placement(transformation(extent={{-106,0},{-86,20}})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation (Placement(
            transformation(extent={{-190,148},{-150,188}}), iconTransformation(
              extent={{-180,160},{-160,180}})));
      Modelica.Blocks.Math.Gain supFanGain(k=designAirFlow)
        annotation (Placement(transformation(extent={{-76,46},{-56,66}})));
      Modelica.Blocks.Nonlinear.Limiter limiter(uMax=designAirFlow, uMin=0)
        annotation (Placement(transformation(extent={{-46,84},{-26,104}})));
      Modelica.Blocks.Continuous.Integrator coolingEnergy(k=designCoolingCOP)
        annotation (Placement(transformation(extent={{80,120},{100,140}})));
      Modelica.Blocks.Continuous.Integrator heatingEnergy(k=designHeatingEfficiency)
        annotation (Placement(transformation(extent={{80,80},{100,100}})));
    equation
      connect(coolCoil.port_b, heatCoil.port_a)
        annotation (Line(points={{56,48},{76,48}}, color={0,127,255}));
      connect(supplyFan.ports[1], coolCoil.port_a)
        annotation (Line(points={{0,48},{36,48}}, color={0,127,255}));
      connect(TheatSetpoint, control_GPC36.TheatSet) annotation (Line(points={{-220,
              130},{-138,130},{-138,17},{-107,17}}, color={0,0,127}));
      connect(TcoolSetpoint, control_GPC36.TcoolSet) annotation (Line(points={{-220,
              78},{-162,78},{-162,12},{-107,12}}, color={0,0,127}));
      connect(Tmea, control_GPC36.Tmea) annotation (Line(points={{-220,0},{-162,0},{
              -162,4},{-107,4}}, color={0,0,127}));
      connect(control_GPC36.fanSet, supFanGain.u) annotation (Line(points={{-85,4},{
              -82,4},{-82,56},{-78,56}}, color={0,0,127}));
      connect(weaBus.TDryBul, control_GPC36.Tout) annotation (Line(
          points={{-170,168},{-170,168},{-170,144},{-114,144},{-114,0},{-107,0}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));

      connect(supFanGain.y, limiter.u) annotation (Line(points={{-55,56},{-52,56},{-52,
              94},{-48,94}}, color={0,0,127}));
      connect(limiter.y, supplyFan.m_flow_in) annotation (Line(points={{-25,94},{-24,
              94},{-24,56},{-20,56}}, color={0,0,127}));
      connect(heatCoil.port_b, supplyAirTemp.port_a) annotation (Line(points={{
              96,48},{104,48},{110,48}}, color={0,127,255}));
      connect(supplyAirTemp.port_b, supplyAir) annotation (Line(points={{130,48},
              {200,48},{200,52}}, color={0,127,255}));
      connect(control_GPC36.coolSAT, coolCoil.TSet) annotation (Line(points={{
              -85,12},{20,12},{20,54},{34,54}}, color={0,0,127}));
      connect(control_GPC36.heatSAT, heatCoil.TSet) annotation (Line(points={{
              -85,16},{-20,16},{66,16},{66,54},{74,54}}, color={0,0,127}));
      connect(coolingEnergy.u, coolCoil.Q_flow) annotation (Line(points={{78,130},{62,
              130},{62,88},{62,54},{57,54}}, color={0,0,127}));
      connect(heatCoil.Q_flow, heatingEnergy.u) annotation (Line(points={{97,54},{100,
              54},{100,66},{74,66},{74,90},{78,90}}, color={0,0,127}));
      connect(Tmea, supplyFan.T_in) annotation (Line(points={{-220,0},{-192,0},
              {-188,0},{-188,36},{-32,36},{-32,52},{-22,52}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},
                {200,160}})),                                        Diagram(
            coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},{200,160}})),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_GPC36;

    model VAV_SingleZone_GPC36_uCoils
      "Single zone VAV HVAC system with GPC36 logic written in CDL with heating and cooling coils controlled using heat inputs"
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate maxAirFlowHeat "Maximum airflow rate of system during heating";
      parameter Modelica.SIunits.Temperature supplyAirTempSet "Cooling supply air temperature setpoint";
      parameter Modelica.SIunits.Power designHeatingCapacity "Design heating capacity of heating coil";
      parameter Real designHeatingEfficiency "Design heating efficiency of the heating coil";
      parameter Modelica.SIunits.Power designCoolingCapacity "Design heating capacity of cooling coil";
      parameter Real designCoolingCOP "Design cooling COP of the cooling coil";
      parameter Real sensitivityGainHeat = 2 "[K] Gain sensitivity on heating controller";
      parameter Real sensitivityGainCool = 2 "[K] Gain sensitivity on cooling controller";
      Modelica.Blocks.Interfaces.RealInput Tmea
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{-20,-20},{20,20}},
            rotation=0,
            origin={-220,0})));
      Buildings.Fluid.Sources.MassFlowSource_T     supplyFan(redeclare package
          Medium = Medium,
        use_m_flow_in=true,
        use_T_in=true,
        nPorts=1)           "Supply air fan"
        annotation (Placement(transformation(extent={{-20,38},{0,58}})));
      Modelica.Fluid.Interfaces.FluidPorts_b supplyAir(redeclare package Medium =
            Medium) "Supply air port"
        annotation (Placement(transformation(extent={{190,12},{210,92}})));
      Modelica.Blocks.Interfaces.RealInput TheatSetpoint
        "Zone heating setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,130})));
      Modelica.Blocks.Interfaces.RealInput TcoolSetpoint
        "Zone cooling setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,78})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u coolCoil(
        redeclare package Medium = Medium,
        Q_flow_nominal=designCoolingCapacity,
        m_flow_nominal=designAirFlow,
        dp_nominal=0,
        u(start=0)) "DX air cooling coil"
        annotation (Placement(transformation(extent={{36,38},{56,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          supplyAirTemp(redeclare package
          Medium =
            Medium, m_flow_nominal=designAirFlow)
        "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{110,38},{130,58}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u heatCoil(
        m_flow_nominal=designAirFlow,
        redeclare package Medium = Medium,
        Q_flow_nominal=designHeatingCapacity,
        dp_nominal=0,
        u(start=0))                           "Air heating coil"
        annotation (Placement(transformation(extent={{76,38},{96,58}})));
      Control_GPC36 control_GPC36(
        designAirFlow=designAirFlow,
        minAirFlow=minAirFlow,
        maxAirFlowHeat=maxAirFlowHeat,
        sensitivityGainHeat=sensitivityGainHeat,
        sensitivityGainCool=sensitivityGainCool)
        annotation (Placement(transformation(extent={{-152,0},{-132,20}})));
      Modelica.Blocks.Continuous.LimPID Pheat(
        Td=0.1,
        Ti=0.08,
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        yMax=1,
        yMin=0,
        k=5e-1) annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={-30,10})));
      Modelica.Blocks.Continuous.LimPID Pcool(
        Td=0.1,
        Ti=0.08,
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        yMax=0,
        yMin=-1,
        k=5e-1) annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={-30,-30})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation (Placement(
            transformation(extent={{-190,148},{-150,188}}), iconTransformation(
              extent={{-180,160},{-160,180}})));
      Modelica.Blocks.Math.Gain supFanGain(k=designAirFlow)
        annotation (Placement(transformation(extent={{-120,50},{-100,70}})));
      Modelica.Blocks.Nonlinear.Limiter limiter(uMax=designAirFlow, uMin=0)
        annotation (Placement(transformation(extent={{-80,80},{-60,100}})));
      Modelica.Blocks.Continuous.Integrator coolingEnergy(k=1)
        annotation (Placement(transformation(extent={{80,120},{100,140}})));
      Modelica.Blocks.Continuous.Integrator heatingEnergy(k=designHeatingEfficiency)
        annotation (Placement(transformation(extent={{80,80},{100,100}})));
      Modelica.Blocks.Math.Gain COP(k=designCoolingCOP)
        annotation (Placement(transformation(extent={{44,120},{64,140}})));
    equation
      connect(coolCoil.port_b, heatCoil.port_a)
        annotation (Line(points={{56,48},{76,48}}, color={0,127,255}));
      connect(supplyFan.ports[1], coolCoil.port_a)
        annotation (Line(points={{0,48},{36,48}}, color={0,127,255}));
      connect(TheatSetpoint, control_GPC36.TheatSet) annotation (Line(points={{-220,
              130},{-166,130},{-166,17},{-153,17}}, color={0,0,127}));
      connect(TcoolSetpoint, control_GPC36.TcoolSet) annotation (Line(points={{-220,78},
              {-190,78},{-190,12},{-153,12}},     color={0,0,127}));
      connect(Tmea, control_GPC36.Tmea) annotation (Line(points={{-220,0},{-190,
              0},{-190,4},{-153,4}},
                                 color={0,0,127}));
      connect(control_GPC36.heatSAT, Pheat.u_s) annotation (Line(points={{-131,16},
              {-131,16},{-60,16},{-60,10},{-42,10}},
                                              color={0,0,127}));
      connect(supplyAirTemp.T, Pheat.u_m) annotation (Line(points={{120,59},{
              120,59},{120,64},{148,64},{148,-6},{-30,-6},{-30,-2}},
                                         color={0,0,127}));
      connect(control_GPC36.coolSAT, Pcool.u_s) annotation (Line(points={{-131,12},
              {-64,12},{-64,-30},{-42,-30}},
                                       color={0,0,127}));
      connect(supplyAirTemp.T, Pcool.u_m) annotation (Line(points={{120,59},{
              120,59},{120,64},{148,64},{148,-44},{-30,-44},{-30,-42}},
                                            color={0,0,127}));
      connect(control_GPC36.fanSet, supFanGain.u) annotation (Line(points={{-131,4},
              {-126,4},{-126,60},{-122,60}},
                                         color={0,0,127}));
      connect(weaBus.TDryBul, control_GPC36.Tout) annotation (Line(
          points={{-170,168},{-170,168},{-170,144},{-160,144},{-160,0},{-153,0}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));

      connect(supFanGain.y, limiter.u) annotation (Line(points={{-99,60},{-92,
              60},{-92,90},{-86,90},{-82,90}},
                             color={0,0,127}));
      connect(limiter.y, supplyFan.m_flow_in) annotation (Line(points={{-59,90},
              {-40,90},{-40,56},{-20,56}},
                                      color={0,0,127}));
      connect(heatCoil.port_b, supplyAirTemp.port_a) annotation (Line(points={{
              96,48},{104,48},{110,48}}, color={0,127,255}));
      connect(supplyAirTemp.port_b, supplyAir) annotation (Line(points={{130,48},
              {200,48},{200,52}}, color={0,127,255}));
      connect(heatCoil.Q_flow, heatingEnergy.u) annotation (Line(points={{97,54},{108,
              54},{108,66},{72,66},{72,90},{78,90}}, color={0,0,127}));
      connect(coolCoil.Q_flow, COP.u) annotation (Line(points={{57,54},{58,54},
              {60,54},{60,90},{26,90},{26,130},{42,130}}, color={0,0,127}));
      connect(COP.y, coolingEnergy.u) annotation (Line(points={{65,130},{70,130},
              {78,130}}, color={0,0,127}));
      connect(Pheat.y, heatCoil.u) annotation (Line(points={{-19,10},{-19,10},{
              68,10},{68,54},{74,54}}, color={0,0,127}));
      connect(Pcool.y, coolCoil.u) annotation (Line(points={{-19,-30},{20,-30},
              {20,54},{34,54}}, color={0,0,127}));
      connect(supplyFan.T_in, control_GPC36.Tmea) annotation (Line(points={{-22,
              52},{-78,52},{-78,34},{-176,34},{-176,4},{-153,4}}, color={0,0,
              127}));
    public
      replaceable package Medium =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component"
          annotation (choicesAllMatching = true);
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},
                {200,160}})),                                        Diagram(
            coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},{200,160}})),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_GPC36_uCoils;

    model VAV_SingleZone_GPC36_dxCoil
      "Single zone VAV HVAC system with GPC36 logic written in CDL with heating and cooling coils controlled using heat inputs"
      replaceable package Medium =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component"
          annotation (choicesAllMatching = true);
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate maxAirFlowHeat "Maximum airflow rate of system during heating";
      parameter Modelica.SIunits.Temperature supplyAirTempSet "Cooling supply air temperature setpoint";
      parameter Modelica.SIunits.Power designHeatingCapacity "Design heating capacity of heating coil";
      parameter Real designHeatingEfficiency "Design heating efficiency of the heating coil";
      parameter Modelica.SIunits.Power designCoolingCapacity "Design heating capacity of cooling coil";
      parameter Real designCoolingCOP "Design cooling COP of the cooling coil";
      parameter Real sensitivityGainHeat = 2 "[K] Gain sensitivity on heating controller";
      parameter Real sensitivityGainCool = 2 "[K] Gain sensitivity on cooling controller";
      Modelica.Blocks.Interfaces.RealInput Tmea
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{-20,-20},{20,20}},
            rotation=0,
            origin={-220,0})));
      Buildings.Fluid.Sources.MassFlowSource_T     supplyFan(redeclare package
          Medium = Medium,
        use_m_flow_in=true,
        use_T_in=true,
        nPorts=1)           "Supply air fan"
        annotation (Placement(transformation(extent={{-20,38},{0,58}})));
      Modelica.Fluid.Interfaces.FluidPorts_b supplyAir(redeclare package Medium =
            Medium) "Supply air port"
        annotation (Placement(transformation(extent={{190,12},{210,92}})));
      Modelica.Fluid.Interfaces.FluidPorts_b returnAir[1](redeclare package Medium =
                   Medium)                               "Return air"
        annotation (Placement(transformation(extent={{190,-100},{210,-20}})));
      Modelica.Blocks.Interfaces.RealInput TheatSetpoint
        "Zone heating setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,130})));
      Modelica.Blocks.Interfaces.RealInput TcoolSetpoint
        "Zone cooling setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,78})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          supplyAirTemp(redeclare package Medium =
            Medium, m_flow_nominal=designAirFlow)
        "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{110,38},{130,58}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u heatCoil(
        m_flow_nominal=designAirFlow,
        redeclare package Medium = Medium,
        Q_flow_nominal=designHeatingCapacity,
        dp_nominal=0,
        u(start=0))                           "Air heating coil"
        annotation (Placement(transformation(extent={{76,38},{96,58}})));
      Buildings.Fluid.Sources.FixedBoundary bou(
        redeclare package Medium = Medium,
        p(displayUnit="Pa") = 101325,
        nPorts=1)
        annotation (Placement(transformation(extent={{-22,-70},{-2,-50}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          returnAirTemp(redeclare package Medium =
                   Medium, m_flow_nominal=designAirFlow)
                           "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{130,-50},{110,-70}})));
      Control_GPC36 control_GPC36(
        designAirFlow=designAirFlow,
        minAirFlow=minAirFlow,
        maxAirFlowHeat=maxAirFlowHeat,
        sensitivityGainHeat=sensitivityGainHeat,
        sensitivityGainCool=sensitivityGainCool)
        annotation (Placement(transformation(extent={{-152,0},{-132,20}})));
      Modelica.Blocks.Continuous.LimPID Pheat(
        Td=0.1,
        Ti=0.08,
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        yMax=1,
        yMin=0,
        k=5e-1) annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={-30,10})));
      Modelica.Blocks.Continuous.LimPID Pcool(
        Td=0.1,
        Ti=0.08,
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        yMax=0,
        yMin=-1,
        k=5e-1) annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={-30,-30})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation (Placement(
            transformation(extent={{-190,148},{-150,188}}), iconTransformation(
              extent={{-180,160},{-160,180}})));
      Modelica.Blocks.Math.Gain supFanGain(k=designAirFlow)
        annotation (Placement(transformation(extent={{-120,50},{-100,70}})));
      Modelica.Blocks.Nonlinear.Limiter limiter(uMax=designAirFlow, uMin=0)
        annotation (Placement(transformation(extent={{-80,80},{-60,100}})));
      Modelica.Blocks.Math.Gain dxGain(k=-1) annotation (Placement(transformation(
            extent={{-4,-4},{4,4}},
            rotation=90,
            origin={28,36})));
      Buildings.Fluid.HeatExchangers.DXCoils.VariableSpeed mulStaDX(
        datCoi=dxCoilPerformance,
        redeclare package Medium = Medium,
        dp_nominal=0,
        minSpeRat=dxCoilPerformance.minSpeRat)
        annotation (Placement(transformation(extent={{36,38},{56,58}})));
      parameter Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.DXCoil
        dxCoilPerformance(nSta=1, sta={
            Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.Stage(
            spe=1,
            nomVal=
              Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.NominalValues(
              Q_flow_nominal=-designCoolingCapacity,
              COP_nominal=designCoolingCOP,
              SHR_nominal=0.8,
              m_flow_nominal=0.75),
            perCur=dxCoilPerformanceCurve)},
        minSpeRat=0)
        annotation (Placement(transformation(extent={{120,142},{140,162}})));
    equation
      connect(returnAirTemp.T, supplyFan.T_in) annotation (Line(points={{120,-71},
              {120,-72},{120,-80},{-80,-80},{-80,52},{-22,52}},
                                            color={0,0,127}));
      connect(TheatSetpoint, control_GPC36.TheatSet) annotation (Line(points={{-220,
              130},{-166,130},{-166,17},{-153,17}}, color={0,0,127}));
      connect(TcoolSetpoint, control_GPC36.TcoolSet) annotation (Line(points={{-220,78},
              {-190,78},{-190,12},{-153,12}},     color={0,0,127}));
      connect(Tmea, control_GPC36.Tmea) annotation (Line(points={{-220,0},{-190,
              0},{-190,4},{-153,4}},
                                 color={0,0,127}));
      connect(control_GPC36.heatSAT, Pheat.u_s) annotation (Line(points={{-131,16},
              {-131,16},{-60,16},{-60,10},{-42,10}},
                                              color={0,0,127}));
      connect(supplyAirTemp.T, Pheat.u_m) annotation (Line(points={{120,59},{
              120,59},{120,64},{148,64},{148,-6},{-30,-6},{-30,-2}},
                                         color={0,0,127}));
      connect(control_GPC36.coolSAT, Pcool.u_s) annotation (Line(points={{-131,12},
              {-64,12},{-64,-30},{-42,-30}},
                                       color={0,0,127}));
      connect(supplyAirTemp.T, Pcool.u_m) annotation (Line(points={{120,59},{
              120,59},{120,64},{148,64},{148,-44},{-30,-44},{-30,-42}},
                                            color={0,0,127}));
      connect(Pheat.y, heatCoil.u) annotation (Line(points={{-19,10},{68,10},{
              68,54},{74,54}},
                        color={0,0,127}));
      connect(control_GPC36.fanSet, supFanGain.u) annotation (Line(points={{-131,4},
              {-126,4},{-126,60},{-122,60}},
                                         color={0,0,127}));
      connect(weaBus.TDryBul, control_GPC36.Tout) annotation (Line(
          points={{-170,168},{-170,168},{-170,144},{-160,144},{-160,0},{-153,0}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));

      connect(supFanGain.y, limiter.u) annotation (Line(points={{-99,60},{-92,
              60},{-92,90},{-82,90}},
                             color={0,0,127}));
      connect(limiter.y, supplyFan.m_flow_in) annotation (Line(points={{-59,90},
              {-40,90},{-40,56},{-20,56}},
                                      color={0,0,127}));
      connect(heatCoil.port_b, supplyAirTemp.port_a) annotation (Line(points={{
              96,48},{104,48},{110,48}}, color={0,127,255}));
      connect(supplyAirTemp.port_b, supplyAir) annotation (Line(points={{130,48},
              {200,48},{200,52}}, color={0,127,255}));
      connect(returnAirTemp.port_a, returnAir[1])
        annotation (Line(points={{130,-60},{200,-60}}, color={0,127,255}));
      connect(returnAirTemp.port_b, bou.ports[1])
        annotation (Line(points={{110,-60},{-2,-60}},color={0,127,255}));
      connect(supplyFan.ports[1], mulStaDX.port_a)
        annotation (Line(points={{0,48},{36,48}}, color={0,127,255}));
      connect(mulStaDX.port_b, heatCoil.port_a)
        annotation (Line(points={{56,48},{56,48},{76,48}}, color={0,127,255}));
      connect(dxGain.y, mulStaDX.speRat)
        annotation (Line(points={{28,40.4},{28,56},{35,56}}, color={0,0,127}));
      connect(weaBus.TDryBul, mulStaDX.TConIn) annotation (Line(
          points={{-170,168},{-170,144},{24,144},{24,51},{35,51}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));
      connect(Pcool.y, dxGain.u) annotation (Line(points={{-19,-30},{28,-30},{
              28,31.2}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},
                {200,160}})),                                        Diagram(
            coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},{200,160}})),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_GPC36_dxCoil;

    model VAV_SingleZone_GPC36_dxCoil_fan
      "Single zone VAV HVAC system with GPC36 logic written in CDL with heating and cooling coils controlled using heat inputs"
      replaceable package Medium =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component"
          annotation (choicesAllMatching = true);
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate maxAirFlowHeat "Maximum airflow rate of system during heating";
      parameter Modelica.SIunits.Temperature supplyAirTempSet "Cooling supply air temperature setpoint";
      parameter Modelica.SIunits.Power designHeatingCapacity "Design heating capacity of heating coil";
      parameter Real designHeatingEfficiency "Design heating efficiency of the heating coil";
      parameter Modelica.SIunits.Power designCoolingCapacity "Design heating capacity of cooling coil";
      parameter Real designCoolingCOP "Design cooling COP of the cooling coil";
      parameter Real sensitivityGainHeat = 2 "[K] Gain sensitivity on heating controller";
      parameter Real sensitivityGainCool = 2 "[K] Gain sensitivity on cooling controller";
      Modelica.Blocks.Interfaces.RealInput Tmea
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{-20,-20},{20,20}},
            rotation=0,
            origin={-220,0})));
      Modelica.Fluid.Interfaces.FluidPorts_b supplyAir(redeclare package Medium =
            Medium) "Supply air port"
        annotation (Placement(transformation(extent={{190,12},{210,92}})));
      Modelica.Fluid.Interfaces.FluidPorts_b returnAir[1](redeclare package
          Medium = Medium)                               "Return air"
        annotation (Placement(transformation(extent={{190,-100},{210,-20}})));
      Modelica.Blocks.Interfaces.RealInput TheatSetpoint
        "Zone heating setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,130})));
      Modelica.Blocks.Interfaces.RealInput TcoolSetpoint
        "Zone cooling setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,78})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          supplyAirTemp(redeclare package
          Medium =
            Medium, m_flow_nominal=designAirFlow)
        "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{110,38},{130,58}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u heatCoil(
        m_flow_nominal=designAirFlow,
        redeclare package Medium = Medium,
        Q_flow_nominal=designHeatingCapacity,
        u(start=0),
        dp_nominal=125)                       "Air heating coil"
        annotation (Placement(transformation(extent={{76,38},{96,58}})));
      Control_GPC36 control_GPC36(
        designAirFlow=designAirFlow,
        minAirFlow=minAirFlow,
        maxAirFlowHeat=maxAirFlowHeat,
        sensitivityGainHeat=sensitivityGainHeat,
        sensitivityGainCool=sensitivityGainCool)
        annotation (Placement(transformation(extent={{-152,0},{-132,20}})));
      Modelica.Blocks.Continuous.LimPID Pheat(
        Td=0.1,
        Ti=0.08,
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        yMax=1,
        yMin=0,
        k=5e-1) annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={-30,10})));
      Modelica.Blocks.Continuous.LimPID Pcool(
        Td=0.1,
        Ti=0.08,
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        yMax=0,
        yMin=-1,
        k=7e-1) annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={-30,-30})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation (Placement(
            transformation(extent={{-190,148},{-150,188}}), iconTransformation(
              extent={{-180,160},{-160,180}})));
      Modelica.Blocks.Math.Gain supFanGain(k=designAirFlow)
        annotation (Placement(transformation(extent={{-120,80},{-100,100}})));
      Modelica.Blocks.Nonlinear.Limiter limiter(uMax=designAirFlow, uMin=0)
        annotation (Placement(transformation(extent={{-80,80},{-60,100}})));
      Modelica.Blocks.Math.Gain dxGain(k=-1) annotation (Placement(transformation(
            extent={{-4,-4},{4,4}},
            rotation=90,
            origin={28,36})));
      Buildings.Fluid.HeatExchangers.DXCoils.VariableSpeed mulStaDX(
        datCoi=dxCoilPerformance,
        redeclare package Medium = Medium,
        minSpeRat=dxCoilPerformance.minSpeRat,
        dp_nominal=125)
        annotation (Placement(transformation(extent={{36,38},{56,58}})));
      parameter Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.DXCoil
        dxCoilPerformance(nSta=1, sta={
            Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.Stage(
            spe=1,
            nomVal=
              Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.NominalValues(
              Q_flow_nominal=-designCoolingCapacity,
              COP_nominal=designCoolingCOP,
              SHR_nominal=0.8,
              m_flow_nominal=0.75),
            perCur=dxCoilPerformanceCurve)},
        minSpeRat=0)
        annotation (Placement(transformation(extent={{120,142},{140,162}})));
      Buildings.Fluid.Movers.FlowControlled_m_flow supplyFan(
        redeclare package Medium = Medium,
        m_flow_nominal=designAirFlow,
        energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
        dp_nominal=250,
        per(use_powerCharacteristic=true, power(V_flow={0,designAirFlow}, P={
                2000*designAirFlow*0.15,2000*designAirFlow})))
        annotation (Placement(transformation(extent={{-40,38},{-20,58}})));
    equation
      connect(TheatSetpoint, control_GPC36.TheatSet) annotation (Line(points={{-220,
              130},{-166,130},{-166,17},{-153,17}}, color={0,0,127}));
      connect(TcoolSetpoint, control_GPC36.TcoolSet) annotation (Line(points={{-220,78},
              {-190,78},{-190,12},{-153,12}},     color={0,0,127}));
      connect(Tmea, control_GPC36.Tmea) annotation (Line(points={{-220,0},{-190,
              0},{-190,4},{-153,4}},
                                 color={0,0,127}));
      connect(control_GPC36.heatSAT, Pheat.u_s) annotation (Line(points={{-131,16},
              {-131,16},{-60,16},{-60,10},{-42,10}},
                                              color={0,0,127}));
      connect(supplyAirTemp.T, Pheat.u_m) annotation (Line(points={{120,59},{
              120,59},{120,64},{148,64},{148,-6},{-30,-6},{-30,-2}},
                                         color={0,0,127}));
      connect(control_GPC36.coolSAT, Pcool.u_s) annotation (Line(points={{-131,12},
              {-64,12},{-64,-30},{-42,-30}},
                                       color={0,0,127}));
      connect(supplyAirTemp.T, Pcool.u_m) annotation (Line(points={{120,59},{
              120,59},{120,64},{148,64},{148,-44},{-30,-44},{-30,-42}},
                                            color={0,0,127}));
      connect(Pheat.y, heatCoil.u) annotation (Line(points={{-19,10},{68,10},{
              68,54},{74,54}},
                        color={0,0,127}));
      connect(control_GPC36.fanSet, supFanGain.u) annotation (Line(points={{-131,4},
              {-126,4},{-126,90},{-122,90}},
                                         color={0,0,127}));
      connect(weaBus.TDryBul, control_GPC36.Tout) annotation (Line(
          points={{-170,168},{-170,168},{-170,144},{-160,144},{-160,0},{-153,0}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));

      connect(supFanGain.y, limiter.u) annotation (Line(points={{-99,90},{-92,
              90},{-82,90}}, color={0,0,127}));
      connect(heatCoil.port_b, supplyAirTemp.port_a) annotation (Line(points={{
              96,48},{104,48},{110,48}}, color={0,127,255}));
      connect(supplyAirTemp.port_b, supplyAir) annotation (Line(points={{130,48},
              {200,48},{200,52}}, color={0,127,255}));
      connect(mulStaDX.port_b, heatCoil.port_a)
        annotation (Line(points={{56,48},{56,48},{76,48}}, color={0,127,255}));
      connect(dxGain.y, mulStaDX.speRat)
        annotation (Line(points={{28,40.4},{28,56},{35,56}}, color={0,0,127}));
      connect(weaBus.TDryBul, mulStaDX.TConIn) annotation (Line(
          points={{-170,168},{-170,144},{24,144},{24,51},{35,51}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));
      connect(Pcool.y, dxGain.u) annotation (Line(points={{-19,-30},{28,-30},{
              28,31.2}}, color={0,0,127}));
      connect(supplyFan.port_b, mulStaDX.port_a)
        annotation (Line(points={{-20,48},{8,48},{36,48}}, color={0,127,255}));
      connect(limiter.y, supplyFan.m_flow_in) annotation (Line(points={{-59,90},
              {-30.2,90},{-30.2,60}}, color={0,0,127}));
      connect(returnAir[1], supplyFan.port_a) annotation (Line(points={{200,-60},
              {70,-60},{-52,-60},{-52,48},{-40,48}}, color={0,127,255}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},
                {200,160}})),                                        Diagram(
            coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},{200,160}})),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_GPC36_dxCoil_fan;

    model VAV_SingleZone_GPC36_uCoils_fan
      "Single zone VAV HVAC system with GPC36 logic written in CDL with heating and cooling coils controlled using heat inputs"
      replaceable package Medium =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component"
          annotation (choicesAllMatching = true);
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate maxAirFlowHeat "Maximum airflow rate of system during heating";
      parameter Modelica.SIunits.Temperature supplyAirTempSet "Cooling supply air temperature setpoint";
      parameter Modelica.SIunits.Power designHeatingCapacity "Design heating capacity of heating coil";
      parameter Real designHeatingEfficiency "Design heating efficiency of the heating coil";
      parameter Modelica.SIunits.Power designCoolingCapacity "Design heating capacity of cooling coil";
      parameter Real designCoolingCOP "Design cooling COP of the cooling coil";
      parameter Real sensitivityGainHeat = 2 "[K] Gain sensitivity on heating controller";
      parameter Real sensitivityGainCool = 2 "[K] Gain sensitivity on cooling controller";
      Modelica.Blocks.Interfaces.RealInput Tmea
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{-20,-20},{20,20}},
            rotation=0,
            origin={-220,0})));
      Modelica.Fluid.Interfaces.FluidPorts_b supplyAir(redeclare package Medium =
            Medium) "Supply air port"
        annotation (Placement(transformation(extent={{190,12},{210,92}})));
      Modelica.Fluid.Interfaces.FluidPorts_b returnAir[1](redeclare package
          Medium = Medium)                               "Return air"
        annotation (Placement(transformation(extent={{190,-100},{210,-20}})));
      Modelica.Blocks.Interfaces.RealInput TheatSetpoint
        "Zone heating setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,130})));
      Modelica.Blocks.Interfaces.RealInput TcoolSetpoint
        "Zone cooling setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,78})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u coolCoil(
        redeclare package Medium = Medium,
        Q_flow_nominal=designCoolingCapacity,
        m_flow_nominal=designAirFlow,
        u(start=0),
        dp_nominal=5)
                    "DX air cooling coil"
        annotation (Placement(transformation(extent={{36,38},{56,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          supplyAirTemp(redeclare package
          Medium =
            Medium, m_flow_nominal=designAirFlow)
        "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{110,38},{130,58}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u heatCoil(
        m_flow_nominal=designAirFlow,
        redeclare package Medium = Medium,
        Q_flow_nominal=designHeatingCapacity,
        u(start=0),
        dp_nominal=5)                         "Air heating coil"
        annotation (Placement(transformation(extent={{76,38},{96,58}})));
      Buildings.Fluid.Sources.FixedBoundary bou(
        redeclare package Medium = Medium,
        p(displayUnit="Pa") = 101325,
        nPorts=1)
        annotation (Placement(transformation(extent={{-20,-70},{0,-50}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          returnAirTemp(redeclare package
          Medium = Medium, m_flow_nominal=designAirFlow)
                           "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{130,-50},{110,-70}})));
      Control_GPC36 control_GPC36(
        designAirFlow=designAirFlow,
        minAirFlow=minAirFlow,
        maxAirFlowHeat=maxAirFlowHeat,
        sensitivityGainHeat=sensitivityGainHeat,
        sensitivityGainCool=sensitivityGainCool)
        annotation (Placement(transformation(extent={{-152,0},{-132,20}})));
      Modelica.Blocks.Continuous.LimPID Pheat(
        Td=0.1,
        Ti=0.08,
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        yMax=1,
        yMin=0,
        k=5e-1) annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={-30,10})));
      Modelica.Blocks.Continuous.LimPID Pcool(
        Td=0.1,
        Ti=0.08,
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        yMax=0,
        yMin=-1,
        k=5e-1) annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={-30,-30})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation (Placement(
            transformation(extent={{-190,148},{-150,188}}), iconTransformation(
              extent={{-180,160},{-160,180}})));
      Modelica.Blocks.Math.Gain supFanGain(k=designAirFlow)
        annotation (Placement(transformation(extent={{-120,80},{-100,100}})));
      Modelica.Blocks.Nonlinear.Limiter limiter(uMax=designAirFlow, uMin=0)
        annotation (Placement(transformation(extent={{-80,80},{-60,100}})));
      Modelica.Blocks.Continuous.Integrator coolingEnergy(k=1)
        annotation (Placement(transformation(extent={{80,120},{100,140}})));
      Modelica.Blocks.Continuous.Integrator heatingEnergy(k=designHeatingEfficiency)
        annotation (Placement(transformation(extent={{80,80},{100,100}})));
      Modelica.Blocks.Math.Gain COP(k=designCoolingCOP)
        annotation (Placement(transformation(extent={{44,120},{64,140}})));
      Buildings.Fluid.Movers.FlowControlled_m_flow supplyFan(
        redeclare package Medium = Medium,
        m_flow_nominal=designAirFlow,
        per(use_powerCharacteristic=true, power(V_flow={0,designAirFlow}, P={
                2000*designAirFlow*0.15,2000*designAirFlow})),
        dp_nominal=10,
        energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState)
        annotation (Placement(transformation(extent={{-20,38},{0,58}})));
      Buildings.Fluid.Sources.Boundary_pT bou1(
        nPorts=1,
        redeclare package Medium = Medium,
        use_T_in=true)
        annotation (Placement(transformation(extent={{-60,38},{-40,58}})));
    equation
      connect(coolCoil.port_b, heatCoil.port_a)
        annotation (Line(points={{56,48},{76,48}}, color={0,127,255}));
      connect(TheatSetpoint, control_GPC36.TheatSet) annotation (Line(points={{-220,
              130},{-166,130},{-166,17},{-153,17}}, color={0,0,127}));
      connect(TcoolSetpoint, control_GPC36.TcoolSet) annotation (Line(points={{-220,78},
              {-190,78},{-190,12},{-153,12}},     color={0,0,127}));
      connect(Tmea, control_GPC36.Tmea) annotation (Line(points={{-220,0},{-190,
              0},{-190,4},{-153,4}},
                                 color={0,0,127}));
      connect(control_GPC36.heatSAT, Pheat.u_s) annotation (Line(points={{-131,16},
              {-131,16},{-60,16},{-60,10},{-42,10}},
                                              color={0,0,127}));
      connect(supplyAirTemp.T, Pheat.u_m) annotation (Line(points={{120,59},{
              120,59},{120,64},{148,64},{148,-6},{-30,-6},{-30,-2}},
                                         color={0,0,127}));
      connect(control_GPC36.coolSAT, Pcool.u_s) annotation (Line(points={{-131,12},
              {-64,12},{-64,-30},{-42,-30}},
                                       color={0,0,127}));
      connect(supplyAirTemp.T, Pcool.u_m) annotation (Line(points={{120,59},{
              120,59},{120,64},{148,64},{148,-44},{-30,-44},{-30,-42}},
                                            color={0,0,127}));
      connect(control_GPC36.fanSet, supFanGain.u) annotation (Line(points={{-131,4},
              {-126,4},{-126,90},{-122,90}},
                                         color={0,0,127}));
      connect(weaBus.TDryBul, control_GPC36.Tout) annotation (Line(
          points={{-170,168},{-170,168},{-170,144},{-160,144},{-160,0},{-153,0}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));

      connect(supFanGain.y, limiter.u) annotation (Line(points={{-99,90},{-92,
              90},{-86,90},{-82,90}},
                             color={0,0,127}));
      connect(heatCoil.port_b, supplyAirTemp.port_a) annotation (Line(points={{
              96,48},{104,48},{110,48}}, color={0,127,255}));
      connect(supplyAirTemp.port_b, supplyAir) annotation (Line(points={{130,48},
              {200,48},{200,52}}, color={0,127,255}));
      connect(returnAirTemp.port_a, returnAir[1])
        annotation (Line(points={{130,-60},{200,-60}}, color={0,127,255}));
      connect(returnAirTemp.port_b, bou.ports[1])
        annotation (Line(points={{110,-60},{0,-60}}, color={0,127,255}));
      connect(heatCoil.Q_flow, heatingEnergy.u) annotation (Line(points={{97,54},{108,
              54},{108,66},{72,66},{72,90},{78,90}}, color={0,0,127}));
      connect(coolCoil.Q_flow, COP.u) annotation (Line(points={{57,54},{58,54},
              {60,54},{60,90},{26,90},{26,130},{42,130}}, color={0,0,127}));
      connect(COP.y, coolingEnergy.u) annotation (Line(points={{65,130},{70,130},
              {78,130}}, color={0,0,127}));
      connect(Pheat.y, heatCoil.u) annotation (Line(points={{-19,10},{-19,10},{
              68,10},{68,54},{74,54}}, color={0,0,127}));
      connect(Pcool.y, coolCoil.u) annotation (Line(points={{-19,-30},{20,-30},
              {20,54},{34,54}}, color={0,0,127}));
      connect(bou1.ports[1], supplyFan.port_a) annotation (Line(points={{-40,48},
              {-30,48},{-20,48}}, color={0,127,255}));
      connect(supplyFan.port_b, coolCoil.port_a)
        annotation (Line(points={{0,48},{18,48},{36,48}}, color={0,127,255}));
      connect(returnAirTemp.T, bou1.T_in) annotation (Line(points={{120,-71},{
              120,-71},{120,-80},{-80,-80},{-80,52},{-62,52}}, color={0,0,127}));
      connect(limiter.y, supplyFan.m_flow_in) annotation (Line(points={{-59,90},
              {-10.2,90},{-10.2,60}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},
                {200,160}})),                                        Diagram(
            coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},{200,160}})),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_GPC36_uCoils_fan;

    model VAV_SingleZone_GPC36_uCoils_fan_mix
      "Single zone VAV HVAC system with dx coil, fan, and mixing box"
      replaceable package Medium =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component"
          annotation (choicesAllMatching = true);
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate maxAirFlowHeat "Maximum airflow rate of system during heating";
      parameter Modelica.SIunits.MassFlowRate minOAFlow "Minimum outside airflow";
      parameter Modelica.SIunits.Temperature supplyAirTempSet "Cooling supply air temperature setpoint";
      parameter Modelica.SIunits.Power designHeatingCapacity "Design heating capacity of heating coil";
      parameter Real designHeatingEfficiency "Design heating efficiency of the heating coil";
      parameter Modelica.SIunits.Power designCoolingCapacity "Design heating capacity of cooling coil";
      parameter Real designCoolingCOP "Design cooling COP of the cooling coil";
      parameter Real sensitivityGainHeat = 2 "[K] Gain sensitivity on heating controller";
      parameter Real sensitivityGainCool = 2 "[K] Gain sensitivity on cooling controller";
      Modelica.Blocks.Interfaces.RealInput Tmea
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{-20,-20},{20,20}},
            rotation=0,
            origin={-220,0})));
      Modelica.Fluid.Interfaces.FluidPorts_b supplyAir(redeclare package Medium =
            Medium) "Supply air port"
        annotation (Placement(transformation(extent={{190,12},{210,92}})));
      Modelica.Fluid.Interfaces.FluidPorts_b returnAir[1](redeclare package
          Medium = Medium)                               "Return air"
        annotation (Placement(transformation(extent={{190,-100},{210,-20}})));
      Modelica.Blocks.Interfaces.RealInput TheatSetpoint
        "Zone heating setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,130})));
      Modelica.Blocks.Interfaces.RealInput TcoolSetpoint
        "Zone cooling setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,78})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          supplyAirTemp(redeclare package
          Medium =
            Medium, m_flow_nominal=designAirFlow) "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{122,38},{142,58}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u heatCoil(
        m_flow_nominal=designAirFlow,
        redeclare package Medium = Medium,
        Q_flow_nominal=designHeatingCapacity,
        u(start=0),
        dp_nominal=0) "Air heating coil"
        annotation (Placement(transformation(extent={{40,38},{60,58}})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation (Placement(
            transformation(extent={{-190,148},{-150,188}}), iconTransformation(
              extent={{-180,160},{-160,180}})));
      parameter Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.DXCoil
        dxCoilPerformance(nSta=1, sta={
            Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.Stage(
            spe=1,
            nomVal=
              Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.NominalValues(
              Q_flow_nominal=-designCoolingCapacity,
              COP_nominal=designCoolingCOP,
              SHR_nominal=0.8,
              m_flow_nominal=0.75),
            perCur=dxCoilPerformanceCurve)},
        minSpeRat=0)
        annotation (Placement(transformation(extent={{120,142},{140,162}})));
      Buildings.Fluid.Movers.FlowControlled_m_flow supplyFan(
        redeclare package Medium = Medium,
        m_flow_nominal=designAirFlow,
        energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
        nominalValuesDefineDefaultPressureCurve=true,
        dp_nominal=500,
        per(use_powerCharacteristic=false))
        annotation (Placement(transformation(extent={{-20,38},{0,58}})));
      Modelica.Blocks.Math.Gain gain(k=1)  annotation (Placement(transformation(
            extent={{4,-4},{-4,4}},
            rotation=-90,
            origin={74,36})));
      Buildings.Fluid.FixedResistances.PressureDrop totalRes(
        m_flow_nominal=designAirFlow,
        dp_nominal=500,
        redeclare package Medium = Medium)
        annotation (Placement(transformation(extent={{10,38},{30,58}})));
      Buildings.Fluid.Sources.Outside out(          redeclare package Medium =
            Medium, nPorts=2)
        annotation (Placement(transformation(extent={{-140,36},{-120,56}})));
      Modelica.Blocks.Sources.Constant constFlow(k=minOAFlow)
        annotation (Placement(transformation(extent={{-140,-30},{-120,-10}})));
      Buildings.Fluid.Sensors.MassFlowRate exhaustAirFlow(redeclare package
          Medium =
            Medium)
        annotation (Placement(transformation(extent={{-30,-70},{-10,-50}})));
      Buildings.Fluid.Sensors.MassFlowRate oaAirFlow(redeclare package Medium =
            Medium)
        annotation (Placement(transformation(extent={{-90,38},{-70,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort mixedAirTemp(redeclare package
          Medium = Medium, m_flow_nominal=designAirFlow)
        "Mixed air temperature sensor"
        annotation (Placement(transformation(extent={{-50,38},{-30,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort returnAirTemp(redeclare
          package Medium =
                   Medium, m_flow_nominal=designAirFlow)
        "Mixed air temperature sensor"
        annotation (Placement(transformation(extent={{70,-70},{90,-50}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u coolCoil(
        m_flow_nominal=designAirFlow,
        redeclare package Medium = Medium,
        u(start=0),
        dp_nominal=0,
        Q_flow_nominal=designCoolingCapacity) "Air cooling coil"
        annotation (Placement(transformation(extent={{80,38},{100,58}})));
      Buildings.Fluid.Movers.FlowControlled_m_flow reliefFan(
        redeclare package Medium = Medium,
        energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
        nominalValuesDefineDefaultPressureCurve=true,
        dp_nominal=500,
        per(use_powerCharacteristic=false),
        m_flow_nominal=minOAFlow)
        annotation (Placement(transformation(extent={{-72,-70},{-92,-50}})));
      Buildings.Fluid.Sensors.MassFlowRate returnAirFlow(redeclare package
          Medium =
            Medium) annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=90,
            origin={-60,-10})));
      Control_GPC36 control_GPC36_1(
        designAirFlow=designAirFlow,
        minAirFlow=minAirFlow,
        maxAirFlowHeat=maxAirFlowHeat,
        sensitivityGainHeat=sensitivityGainHeat,
        sensitivityGainCool=sensitivityGainCool)
        annotation (Placement(transformation(extent={{-140,0},{-120,20}})));
      Modelica.Blocks.Continuous.LimPID Pheat(
        Td=0.1,
        Ti=0.08,
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        yMax=1,
        yMin=0,
        k=5e-1) annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={-10,12})));
      Modelica.Blocks.Continuous.LimPID Pcool(
        Td=0.1,
        Ti=0.08,
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        yMax=0,
        yMin=-1,
        k=5e-1) annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={-10,-28})));
      Modelica.Blocks.Math.Gain supFanGain(k=designAirFlow)
        annotation (Placement(transformation(extent={{-100,90},{-80,110}})));
      Modelica.Blocks.Nonlinear.Limiter limiter(uMax=designAirFlow, uMin=0)
        annotation (Placement(transformation(extent={{-60,90},{-40,110}})));
    equation

      connect(supplyAirTemp.port_b, supplyAir) annotation (Line(points={{142,48},{200,
              48},{200,52}},      color={0,127,255}));
      connect(weaBus, out.weaBus) annotation (Line(
          points={{-170,168},{-170,144},{-170,46.2},{-140,46.2}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));
      connect(oaAirFlow.port_a, out.ports[1])
        annotation (Line(points={{-90,48},{-106,48},{-106,48},{-120,48}},
                                                      color={0,127,255}));
      connect(oaAirFlow.port_b, mixedAirTemp.port_a)
        annotation (Line(points={{-70,48},{-60,48},{-50,48}}, color={0,127,255}));
      connect(exhaustAirFlow.port_b, returnAirTemp.port_a)
        annotation (Line(points={{-10,-60},{30,-60},{70,-60}}, color={0,127,255}));
      connect(returnAirTemp.port_b, returnAir[1]) annotation (Line(points={{90,-60},
              {200,-60},{200,-60}}, color={0,127,255}));
      connect(totalRes.port_b, heatCoil.port_a)
        annotation (Line(points={{30,48},{40,48}}, color={0,127,255}));
      connect(mixedAirTemp.port_b, supplyFan.port_a)
        annotation (Line(points={{-30,48},{-25,48},{-20,48}}, color={0,127,255}));
      connect(supplyFan.port_b, totalRes.port_a)
        annotation (Line(points={{0,48},{6,48},{10,48}}, color={0,127,255}));
      connect(heatCoil.port_b, coolCoil.port_a)
        annotation (Line(points={{60,48},{70,48},{80,48}}, color={0,127,255}));
      connect(gain.y, coolCoil.u)
        annotation (Line(points={{74,40.4},{74,54},{78,54}}, color={0,0,127}));
      connect(coolCoil.port_b, supplyAirTemp.port_a)
        annotation (Line(points={{100,48},{111,48},{122,48}}, color={0,127,255}));
      connect(constFlow.y, reliefFan.m_flow_in) annotation (Line(points={{-119,-20},
              {-100,-20},{-81.8,-20},{-81.8,-48}}, color={0,0,127}));
      connect(reliefFan.port_b, out.ports[2]) annotation (Line(points={{-92,-60},{-98,
              -60},{-100,-60},{-100,44},{-116,44},{-120,44}}, color={0,127,255}));
      connect(returnAirFlow.port_b, mixedAirTemp.port_a)
        annotation (Line(points={{-60,0},{-60,48},{-50,48}}, color={0,127,255}));
      connect(returnAirFlow.port_a, exhaustAirFlow.port_a) annotation (Line(points={
              {-60,-20},{-60,-20},{-60,-60},{-30,-60}}, color={0,127,255}));
      connect(reliefFan.port_a, exhaustAirFlow.port_a)
        annotation (Line(points={{-72,-60},{-30,-60}}, color={0,127,255}));
      connect(weaBus.TDryBul, control_GPC36_1.Tout) annotation (Line(
          points={{-170,168},{-170,144},{-170,0},{-141,0}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));
      connect(TheatSetpoint, control_GPC36_1.TheatSet) annotation (Line(points={{-220,
              130},{-174,130},{-174,17},{-141,17}}, color={0,0,127}));
      connect(TcoolSetpoint, control_GPC36_1.TcoolSet) annotation (Line(points={{-220,
              78},{-180,78},{-180,12},{-141,12}}, color={0,0,127}));
      connect(Tmea, control_GPC36_1.Tmea) annotation (Line(points={{-220,0},{-180,0},
              {-180,4},{-141,4}}, color={0,0,127}));
      connect(control_GPC36_1.fanSet, supFanGain.u) annotation (Line(points={{-119,4},
              {-108,4},{-108,100},{-102,100}}, color={0,0,127}));
      connect(supFanGain.y, limiter.u)
        annotation (Line(points={{-79,100},{-79,100},{-62,100}}, color={0,0,127}));
      connect(limiter.y, supplyFan.m_flow_in) annotation (Line(points={{-39,100},{-10.2,
              100},{-10.2,60}}, color={0,0,127}));
      connect(control_GPC36_1.heatSAT, Pheat.u_s) annotation (Line(points={{-119,16},
              {-78,16},{-38,16},{-38,12},{-22,12}}, color={0,0,127}));
      connect(control_GPC36_1.coolSAT, Pcool.u_s) annotation (Line(points={{-119,12},
              {-40,12},{-40,-28},{-22,-28}}, color={0,0,127}));
      connect(supplyAirTemp.T, Pheat.u_m) annotation (Line(points={{132,59},{132,68},
              {152,68},{152,-10},{-10,-10},{-10,0}}, color={0,0,127}));
      connect(Pcool.u_m, Pheat.u_m) annotation (Line(points={{-10,-40},{-10,-46},{152,
              -46},{152,-10},{-10,-10},{-10,0}}, color={0,0,127}));
      connect(Pheat.y, heatCoil.u) annotation (Line(points={{1,12},{34,12},{34,54},{
              38,54}}, color={0,0,127}));
      connect(Pcool.y, gain.u)
        annotation (Line(points={{1,-28},{74,-28},{74,31.2}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},
                {200,160}})),                                        Diagram(
            coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},{200,160}})),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_GPC36_uCoils_fan_mix;

  end HVACSystems;

  package Loads "Package containing internal loads"

  end Loads;

  package Constructions
    "Package containing the constructions needed for thermal envelope modeling"
    record ASHRAE_189_1_2009_ExtWall_Mass_ClimateZone_5 =
      Buildings.HeatTransfer.Data.OpaqueConstructions.Generic (
        nLay = 4,
        material = {SOEPDemo.Constructions.Materials.Stucco(),
                    SOEPDemo.Constructions.Materials.Concrete(),
                    SOEPDemo.Constructions.Materials.Insulation(),
                    SOEPDemo.Constructions.Materials.Gypsum()},
        absIR_a = 0.9,
        absIR_b = 0.9,
        absSol_a = 0.92,
        absSol_b = 0.40,
        roughness_a = Buildings.HeatTransfer.Types.SurfaceRoughness.Smooth)
      "Construction of ASHRAE 189.1-2009 ExtWall Mass ClimateZone 5";

    record ASHRAE_189_1_2009_ExtRoof_IEAD_ClimateZone_5 =
      Buildings.HeatTransfer.Data.OpaqueConstructions.Generic (
        nLay = 3,
        material = {SOEPDemo.Constructions.Materials.RoofMembrane(),
                    SOEPDemo.Constructions.Materials.RoofInsulation(),
                    SOEPDemo.Constructions.Materials.MetalDecking()},
        absIR_a = 0.9,
        absIR_b = 0.9,
        absSol_a = 0.70,
        absSol_b = 0.60,
        roughness_a = Buildings.HeatTransfer.Types.SurfaceRoughness.VeryRough)
      "Construction of roof with R31 insulation";
    record WALL13 =
      Buildings.HeatTransfer.Data.OpaqueConstructions.Generic (
        nLay = 1,
        material = {SOEPDemo.Constructions.Materials.R13LAYER()},
        absIR_a = 0.9,
        absIR_b = 0.9,
        absSol_a = 0.75,
        absSol_b = 0.75,
        roughness_a = Buildings.HeatTransfer.Types.SurfaceRoughness.Rough)
      "Construction of R13 wall";
    record ROOF31 =
      Buildings.HeatTransfer.Data.OpaqueConstructions.Generic (
        nLay = 1,
        material = {SOEPDemo.Constructions.Materials.R31LAYER()},
        absIR_a = 0.9,
        absIR_b = 0.9,
        absSol_a = 0.75,
        absSol_b = 0.75,
        roughness_a = Buildings.HeatTransfer.Types.SurfaceRoughness.Rough)
        "Construction of roof with R31 insulation";

    record FLOOR =
      Buildings.HeatTransfer.Data.OpaqueConstructions.Generic (
        nLay = 1,
        material = {SOEPDemo.Constructions.Materials.C5_4IN_HW_CONCRETE()},
        absIR_a = 0.9,
        absIR_b = 0.9,
        absSol_a = 0.65,
        absSol_b = 0.65,
        roughness_a = Buildings.HeatTransfer.Types.SurfaceRoughness.Medium)
        "Construction of floor with 4 in HW concrete";

    package Materials
      "Package containing the materials needed for constructions"

      record R13LAYER =
        Buildings.HeatTransfer.Data.Solids.Generic (
          x = 2.290965,
          k = 1,
          d = 0,
          c = 0)
          "NoMass material layer of R13 insulation";

      record R31LAYER =
        Buildings.HeatTransfer.Data.Solids.Generic (
          x = 5.456,
          k = 1,
          d = 0,
          c = 0)
          "NoMass material layer of R31 insulation";

      record C5_4IN_HW_CONCRETE =
        Buildings.HeatTransfer.Data.Solids.Generic (
          x = 0.1014984,
          k=1.729577,
          d=2242.585,
          c=836.8)
          "Material layer for 4 in heavyweight concrete";

      record Stucco =
        Buildings.HeatTransfer.Data.Solids.Generic (
          x = 0.025300,
          k=0.691800,
          d=1858.00,
          c=837.00)
          "Material layer for 1 IN stucco";

      record Concrete =
        Buildings.HeatTransfer.Data.Solids.Generic (
          x = 0.203300,
          k=1.729600,
          d=2243.00,
          c=837.00,
          nStaReal = 5)
          "Material layer for 8 IN heavyweight concrete";

      record Insulation =
        Buildings.HeatTransfer.Data.Solids.Generic (
          x = 0.079400,
          k=0.043200,
          d=91.00,
          c=837.00)
          "Material layer for R40 insulation";

      record Gypsum =
        Buildings.HeatTransfer.Data.Solids.Generic (
          x = 0.012700,
          k=0.160,
          d=784.9,
          c=830.0)
          "Material layer for 1/2 IN Gypsum";

      record RoofMembrane =
        Buildings.HeatTransfer.Data.Solids.Generic (
          x = 0.009500,
          k=0.1600,
          d=1121.2900,
          c=1460.00)
          "Material layer for roofing membrane";

      record RoofInsulation =
        Buildings.HeatTransfer.Data.Solids.Generic (
          x = 0.210500,
          k=0.04900,
          d=265.00,
          c=836.800)
          "Material layer for R21 roof insulation";

      record MetalDecking =
        Buildings.HeatTransfer.Data.Solids.Generic (
          x = 0.001500,
          k=45.0060,
          d=7680.0,
          c=418.4)
          "Material layer for metal decking";

    end Materials;
  end Constructions;

  package Examples

    model FreeFloat_SingleZone
      ThermalEnvelope.Case600FF singleZoneUncontrolled(lat=weaDat.lat)
        annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=
            "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos")
        annotation (Placement(transformation(extent={{-60,20},{-40,40}})));
    equation
      connect(weaDat.weaBus, singleZoneUncontrolled.weaBus) annotation (Line(
          points={{-40,30},{-9,30},{-9,10.4}},
          color={255,204,51},
          thickness=0.5));
      annotation (
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-06,
          __Dymola_Algorithm="Radau"));
    end FreeFloat_SingleZone;

    model IdealHVAC_SingleZone "Test for on off heater and cooler"
      ThermalEnvelope.Case600_IdealHVAC      singleZoneIdealHVAC(lat=weaDat.lat)
        annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=
            "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos")
        annotation (Placement(transformation(extent={{-100,20},{-80,40}})));
      HVACSystems.IdealAir_P  idealAir(sensitivityGainHeat=1,
          sensitivityGainCool=1)
        annotation (Placement(transformation(extent={{-60,40},{-40,60}})));
      Modelica.Blocks.Continuous.Integrator heatingEnergy
        annotation (Placement(transformation(extent={{60,0},{80,20}})));
      Modelica.Blocks.Continuous.Integrator coolingEnergy
        annotation (Placement(transformation(extent={{60,-40},{80,-20}})));
    equation
      connect(weaDat.weaBus, singleZoneIdealHVAC.weaBus) annotation (Line(
          points={{-80,30},{-9,30},{-9,10.4}},
          color={255,204,51},
          thickness=0.5));
      connect(singleZoneIdealHVAC.zoneMeanAirTemperature, idealAir.Tmea)
        annotation (Line(points={{11,0},{40,0},{40,38},{-68,38},{-68,46},{-62,46}},
            color={0,0,127}));
      connect(singleZoneIdealHVAC.TcoolSetpoint, idealAir.TcoolSetpoint)
        annotation (Line(points={{11,-8},{54,-8},{54,80},{-68,80},{-68,53},{-62,
              53}}, color={0,0,127}));
      connect(singleZoneIdealHVAC.TheatSetpoint, idealAir.TheatSetpoint)
        annotation (Line(points={{11,-6},{30,-6},{30,-4},{50,-4},{50,70},{-66,
              70},{-66,57},{-62,57}}, color={0,0,127}));
      connect(singleZoneIdealHVAC.heatingPower, heatingEnergy.u) annotation (
          Line(points={{11,8},{34,8},{34,10},{58,10}}, color={0,0,127}));
      connect(singleZoneIdealHVAC.coolingPower, coolingEnergy.u) annotation (
          Line(points={{11,6},{36,6},{36,-30},{58,-30}}, color={0,0,127}));
      connect(idealAir.supplyAirCool[1], singleZoneIdealHVAC.supplyAirCool)
        annotation (Line(points={{-39.6,51.4},{0,51.4},{0,11}}, color={0,127,
              255}));
      connect(idealAir.supplyAirHeat[1], singleZoneIdealHVAC.supplyAirHeat)
        annotation (Line(points={{-39.6,56},{-5,56},{-5,11}}, color={0,127,255}));
      annotation (
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-06,
          __Dymola_Algorithm="Radau"));
    end IdealHVAC_SingleZone;

    model VAV_SingleZone_Flow "Example for SingleZoneVAV"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      Modelica.Blocks.Sources.Constant TheatSet(k=273.15 + 20)
        annotation (Placement(transformation(extent={{-100,48},{-80,68}})));
      Modelica.Blocks.Sources.Constant TcoolSet(k=273.15 + 25)
        annotation (Placement(transformation(extent={{-102,0},{-82,20}})));
      Buildings.Fluid.Sources.MassFlowSource_T boundary(
        use_m_flow_in=true,
        use_T_in=true,
        redeclare package Medium = MediumA,
        nPorts=1) annotation (Placement(transformation(extent={{78,-10},{58,10}})));
      Buildings.Fluid.Sources.FixedBoundary bou(nPorts=1, redeclare package
          Medium = MediumA)
        annotation (Placement(transformation(extent={{80,20},{60,40}})));
      Buildings.Fluid.Sensors.MassFlowRate senMasFlo(redeclare package Medium =
            MediumA)
        annotation (Placement(transformation(extent={{30,20},{50,40}})));
      Buildings.Fluid.Sensors.Temperature senTem(redeclare package Medium =
            MediumA)
        annotation (Placement(transformation(extent={{10,60},{30,80}})));
      HVACSystems.VAV_SingleZone vAV_SingleZone(
        redeclare package Medium = MediumA,
        sensitivityGain=2,
        designAirFlow=0.25,
        minAirFlow=0.2*25,
        supplyAirTempSet=286.15,
        designHeatingCapacity=1000,
        designCoolingCapacity=1000)
        annotation (Placement(transformation(extent={{-42,-10},{-2,22}})));
      Modelica.Blocks.Sources.Ramp zoneTemperature(
        offset=273.15 + 15,
        startTime=3600*5,
        duration=10800*2,
        height=15)
        annotation (Placement(transformation(extent={{24,-42},{44,-22}})));
    equation
      connect(bou.ports[1], senMasFlo.port_b)
        annotation (Line(points={{60,30},{50,30}}, color={0,127,255}));
      connect(senMasFlo.m_flow, boundary.m_flow_in) annotation (Line(points={{40,41},
              {40,50},{94,50},{94,8},{78,8}}, color={0,0,127}));
      connect(vAV_SingleZone.supplyAir, senMasFlo.port_a) annotation (Line(
            points={{-2,11.2},{4,11.2},{4,12},{12,12},{12,30},{30,30}}, color={
              0,127,255}));
      connect(senMasFlo.port_a, senTem.port)
        annotation (Line(points={{30,30},{20,30},{20,60}}, color={0,127,255}));
      connect(boundary.ports[1:1], vAV_SingleZone.returnAir)
        annotation (Line(points={{58,0},{-2,0}}, color={0,127,255}));
      connect(TheatSet.y, vAV_SingleZone.TheatSetpoint) annotation (Line(points=
             {{-79,58},{-62,58},{-62,19},{-44,19}}, color={0,0,127}));
      connect(TcoolSet.y, vAV_SingleZone.TcoolSetpoint) annotation (Line(points=
             {{-81,10},{-62,10},{-62,13.8},{-44,13.8}}, color={0,0,127}));
      connect(boundary.T_in, zoneTemperature.y) annotation (Line(points={{80,4},
              {90,4},{90,-32},{45,-32}}, color={0,0,127}));
      connect(zoneTemperature.y, vAV_SingleZone.Tmea) annotation (Line(points={
              {45,-32},{62,-32},{62,-14},{-56,-14},{-56,6},{-44,6}}, color={0,0,
              127}));
      annotation (
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        experiment(
          StopTime=86400,
          Interval=60,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_Flow;

    model VAV_SingleZone_Controls "Example for SingleZoneVAV"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      Modelica.Blocks.Sources.Constant TheatSet(k=273.15 + 20)
        annotation (Placement(transformation(extent={{-100,48},{-80,68}})));
      Modelica.Blocks.Sources.Constant TcoolSet(k=273.15 + 25)
        annotation (Placement(transformation(extent={{-102,0},{-82,20}})));
      Modelica.Blocks.Sources.Ramp zoneTemperature(
        duration=5400,
        startTime=0,
        height=20,
        offset=273.15 + 15)
        annotation (Placement(transformation(extent={{-100,-40},{-80,-20}})));
      HVACSystems.Control control(designAirFlow=0.077, minAirFlow=0.1*0.077)
        annotation (Placement(transformation(extent={{-16,-16},{4,4}})));
    equation
      connect(TheatSet.y, control.TheatSet) annotation (Line(points={{-79,58},{
              -48,58},{-48,1},{-17,1}}, color={0,0,127}));
      connect(TcoolSet.y, control.TcoolSet) annotation (Line(points={{-81,10},{
              -50,10},{-50,-4},{-17,-4}}, color={0,0,127}));
      connect(zoneTemperature.y, control.Tmea) annotation (Line(points={{-79,
              -30},{-47.5,-30},{-47.5,-13.2},{-17,-13.2}}, color={0,0,127}));
      annotation (
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        experiment(
          StopTime=7200,
          Interval=60,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_Controls;

    model VAV_SingleZone_dxCoil_fan "Example for SingleZoneVAV"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      HVACSystems.VAV_SingleZone_dxCoilSingle_fan
                                 vAV_SingleZone(
        redeclare package Medium = MediumA,
        designAirFlow=0.75,
        minAirFlow=0.2*0.75,
        designHeatingCapacity=7000,
        sensitivityGainHeat=0.25,
        designHeatingEfficiency=0.99,
        designCoolingCOP=3,
        designCoolingCapacity=7000,
        dxCoilPerformance(sta={
              Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.Stage(
                  spe=1,
                  nomVal=
                Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.NominalValues(
                    Q_flow_nominal=-7000,
                    COP_nominal=3,
                    SHR_nominal=0.8,
                    m_flow_nominal=0.75),
                  perCur=dxCoilPerformanceCurve)}),
        sensitivityGainCool=0.25,
        supplyAirTempSet=286.15)
        annotation (Placement(transformation(extent={{-40,-10},{0,22}})));
      ThermalEnvelope.Case600_AirHVAC   singleZoneAirHVAC(
          designAirFlow=0.75, lat=weaDat.lat)
        annotation (Placement(transformation(extent={{32,-4},{52,16}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=
            "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos")
        annotation (Placement(transformation(extent={{-100,80},{-80,100}})));
      Buildings.Fluid.HeatExchangers.DXCoils.Examples.PerformanceCurves.Curve_II
        dxCoilPerformanceCurve
        annotation (Placement(transformation(extent={{60,80},{80,100}})));
      Modelica.Blocks.Continuous.Integrator totalFanEnergy
        annotation (Placement(transformation(extent={{20,-60},{40,-40}})));
      Modelica.Blocks.Continuous.Integrator totalHeatingEnergy
        annotation (Placement(transformation(extent={{20,-80},{40,-60}})));
      Modelica.Blocks.Continuous.Integrator totalCoolingEnergy
        annotation (Placement(transformation(extent={{20,-100},{40,-80}})));
      Modelica.Blocks.Math.Sum totalHVACEnergy(nin=3)
        annotation (Placement(transformation(extent={{60,-80},{80,-60}})));
    equation
      connect(weaDat.weaBus, singleZoneAirHVAC.weaBus) annotation (Line(
          points={{-80,90},{-26,90},{33,90},{33,16.4}},
          color={255,204,51},
          thickness=0.5));
      connect(vAV_SingleZone.supplyAir, singleZoneAirHVAC.supplyAir)
        annotation (Line(points={{0,11.2},{4,11.2},{4,10},{14,10},{14,28},{38,
              28},{38,17}},          color={0,127,255}));
      connect(singleZoneAirHVAC.zoneMeanAirTemperature, vAV_SingleZone.Tmea)
        annotation (Line(points={{53,6},{60,6},{70,6},{70,-20},{-64,-20},{-64,6},
              {-42,6}},         color={0,0,127}));
      connect(singleZoneAirHVAC.TcoolSetpoint, vAV_SingleZone.TcoolSetpoint)
        annotation (Line(points={{53,-2},{62,-2},{62,-18},{-60,-18},{-60,13.8},
              {-42,13.8}}, color={0,0,127}));
      connect(singleZoneAirHVAC.TheatSetpoint, vAV_SingleZone.TheatSetpoint)
        annotation (Line(points={{53,0},{64,0},{64,-16},{-54,-16},{-54,19},{-42,
              19}}, color={0,0,127}));
      connect(singleZoneAirHVAC.returnAir, vAV_SingleZone.returnAir[1])
        annotation (Line(points={{44,17},{44,24},{18,24},{18,0},{0,0}}, color={
              0,127,255}));
      connect(weaDat.weaBus, vAV_SingleZone.weaBus) annotation (Line(
          points={{-80,90},{-37,90},{-37,23}},
          color={255,204,51},
          thickness=0.5));
      connect(vAV_SingleZone.fanPower, totalFanEnergy.u) annotation (Line(
            points={{1,22},{8,22},{8,-50},{18,-50}}, color={0,0,127}));
      connect(vAV_SingleZone.heatCoilPower, totalHeatingEnergy.u) annotation (
          Line(points={{1,20},{6,20},{6,-70},{18,-70}}, color={0,0,127}));
      connect(vAV_SingleZone.coolCoilPower, totalCoolingEnergy.u) annotation (
          Line(points={{1,18},{4,18},{4,-90},{18,-90}}, color={0,0,127}));
      connect(totalFanEnergy.y, totalHVACEnergy.u[1]) annotation (Line(points={{41,-50},
              {48,-50},{48,-71.3333},{58,-71.3333}},          color={0,0,127}));
      connect(totalHeatingEnergy.y, totalHVACEnergy.u[2]) annotation (Line(
            points={{41,-70},{49.5,-70},{58,-70}}, color={0,0,127}));
      connect(totalCoolingEnergy.y, totalHVACEnergy.u[3]) annotation (Line(
            points={{41,-90},{50,-90},{50,-68.6667},{58,-68.6667}}, color={0,0,
              127}));
      annotation (
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-06,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_dxCoil_fan;

    model VAV_SingleZone_uCoils_fan_mix "Example for SingleZoneVAV"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      HVACSystems.VAV_SingleZone_uCoils_fan_mix
                                 vAV_SingleZone(
        redeclare package Medium = MediumA,
        designCoolingCapacity=7000,
        designHeatingEfficiency=0.99,
        designCoolingCOP=3,
        designAirFlow=1,
        minAirFlow=0.2*1,
        designHeatingCapacity=10000,
        sensitivityGainHeat=3,
        minOAFlow=0.1*1,
        supplyAirTempSet=286.15,
        sensitivityGainCool=2)
        annotation (Placement(transformation(extent={{-40,-10},{0,22}})));
      ThermalEnvelope.Case610_NoInf_AirHVAC
                                        singleZoneAirHVAC(
          designAirFlow=0.75, lat=weaDat.lat)
        annotation (Placement(transformation(extent={{32,-4},{52,16}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=
            "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos")
        annotation (Placement(transformation(extent={{-100,80},{-80,100}})));
    equation
      connect(weaDat.weaBus, singleZoneAirHVAC.weaBus) annotation (Line(
          points={{-80,90},{-26,90},{33,90},{33,16.4}},
          color={255,204,51},
          thickness=0.5));
      connect(vAV_SingleZone.supplyAir, singleZoneAirHVAC.supplyAir)
        annotation (Line(points={{0,11.2},{4,11.2},{4,10},{14,10},{14,28},{38,
              28},{38,17}},          color={0,127,255}));
      connect(singleZoneAirHVAC.zoneMeanAirTemperature, vAV_SingleZone.Tmea)
        annotation (Line(points={{53,6},{60,6},{70,6},{70,-20},{-64,-20},{-64,6},
              {-42,6}},         color={0,0,127}));
      connect(singleZoneAirHVAC.TcoolSetpoint, vAV_SingleZone.TcoolSetpoint)
        annotation (Line(points={{53,-2},{62,-2},{62,-18},{-60,-18},{-60,13.8},
              {-42,13.8}}, color={0,0,127}));
      connect(singleZoneAirHVAC.TheatSetpoint, vAV_SingleZone.TheatSetpoint)
        annotation (Line(points={{53,0},{64,0},{64,-16},{-54,-16},{-54,19},{-42,
              19}}, color={0,0,127}));
      connect(singleZoneAirHVAC.returnAir, vAV_SingleZone.returnAir[1])
        annotation (Line(points={{44,17},{44,24},{18,24},{18,0},{0,0}}, color={
              0,127,255}));
      connect(weaDat.weaBus, vAV_SingleZone.weaBus) annotation (Line(
          points={{-80,90},{-37,90},{-37,23}},
          color={255,204,51},
          thickness=0.5));
      annotation (
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_uCoils_fan_mix;

    model VAV_SingleZone_GPC36 "Example for SingleZoneVAV"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      HVACSystems.VAV_SingleZone_GPC36
                                 vAV_SingleZone(
        redeclare package Medium = MediumA,
        designAirFlow=0.75,
        minAirFlow=0.2*0.75,
        designHeatingCapacity=7000,
        maxAirFlowHeat=0.5*0.75,
        sensitivityGainCool=0.75,
        sensitivityGainHeat=0.25,
        designHeatingEfficiency=0.99,
        designCoolingCOP=3,
        supplyAirTempSet=286.15,
        designCoolingCapacity=7000)
        annotation (Placement(transformation(extent={{-40,-10},{0,22}})));
      ThermalEnvelope.Case610_AirHVAC_SupplyOnly
                                        singleZoneAirHVAC(designAirFlow=0.75, lat=
            weaDat.lat)
        annotation (Placement(transformation(extent={{32,-4},{52,16}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=
            "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos")
        annotation (Placement(transformation(extent={{-100,80},{-80,100}})));
    equation
      connect(weaDat.weaBus, singleZoneAirHVAC.weaBus) annotation (Line(
          points={{-80,90},{-26,90},{33,90},{33,16.4}},
          color={255,204,51},
          thickness=0.5));
      connect(vAV_SingleZone.supplyAir, singleZoneAirHVAC.supplyAir)
        annotation (Line(points={{0,11.2},{4,11.2},{4,10},{14,10},{14,28},{38,
              28},{38,17}},          color={0,127,255}));
      connect(singleZoneAirHVAC.zoneMeanAirTemperature, vAV_SingleZone.Tmea)
        annotation (Line(points={{53,6},{60,6},{70,6},{70,-22},{-64,-22},{-64,6},
              {-42,6}},         color={0,0,127}));
      connect(singleZoneAirHVAC.TcoolSetpoint, vAV_SingleZone.TcoolSetpoint)
        annotation (Line(points={{53,-2},{62,-2},{62,-18},{-60,-18},{-60,13.8},
              {-42,13.8}}, color={0,0,127}));
      connect(singleZoneAirHVAC.TheatSetpoint, vAV_SingleZone.TheatSetpoint)
        annotation (Line(points={{53,0},{66,0},{66,-6},{-52,-6},{-52,19},{-42,
              19}}, color={0,0,127}));
      connect(weaDat.weaBus, vAV_SingleZone.weaBus) annotation (Line(
          points={{-80,90},{-37,90},{-37,23}},
          color={255,204,51},
          thickness=0.5));
      annotation (
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_GPC36;

    model VAV_SingleZone_GPC36_uCoils "Example for SingleZoneVAV"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      HVACSystems.VAV_SingleZone_GPC36_uCoils
                                 vAV_SingleZone(
        redeclare package Medium = MediumA,
        designAirFlow=0.75,
        minAirFlow=0.2*0.75,
        designHeatingCapacity=7000,
        maxAirFlowHeat=0.5*0.75,
        sensitivityGainCool=0.75,
        sensitivityGainHeat=0.25,
        designHeatingEfficiency=0.99,
        designCoolingCOP=3,
        supplyAirTempSet=286.15,
        designCoolingCapacity=7000)
        annotation (Placement(transformation(extent={{-40,-10},{0,22}})));
      ThermalEnvelope.Case610_AirHVAC_SupplyOnly
                                        singleZoneAirHVAC(designAirFlow=0.75, lat=
            weaDat.lat)
        annotation (Placement(transformation(extent={{32,-4},{52,16}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=
            "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos")
        annotation (Placement(transformation(extent={{-100,80},{-80,100}})));
    equation
      connect(weaDat.weaBus, singleZoneAirHVAC.weaBus) annotation (Line(
          points={{-80,90},{-26,90},{33,90},{33,16.4}},
          color={255,204,51},
          thickness=0.5));
      connect(vAV_SingleZone.supplyAir, singleZoneAirHVAC.supplyAir)
        annotation (Line(points={{0,11.2},{4,11.2},{4,10},{14,10},{14,28},{38,
              28},{38,17}},          color={0,127,255}));
      connect(singleZoneAirHVAC.zoneMeanAirTemperature, vAV_SingleZone.Tmea)
        annotation (Line(points={{53,6},{60,6},{70,6},{70,-22},{-64,-22},{-64,6},
              {-42,6}},         color={0,0,127}));
      connect(singleZoneAirHVAC.TcoolSetpoint, vAV_SingleZone.TcoolSetpoint)
        annotation (Line(points={{53,-2},{62,-2},{62,-18},{-60,-18},{-60,13.8},
              {-42,13.8}}, color={0,0,127}));
      connect(singleZoneAirHVAC.TheatSetpoint, vAV_SingleZone.TheatSetpoint)
        annotation (Line(points={{53,0},{66,0},{66,-6},{-52,-6},{-52,19},{-42,
              19}}, color={0,0,127}));
      connect(weaDat.weaBus, vAV_SingleZone.weaBus) annotation (Line(
          points={{-80,90},{-37,90},{-37,23}},
          color={255,204,51},
          thickness=0.5));
      annotation (
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_GPC36_uCoils;

    model VAV_SingleZone_GPC36_dxCoil "Example for SingleZoneVAV"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      HVACSystems.VAV_SingleZone_GPC36_dxCoil
                                 vAV_SingleZone(
        redeclare package Medium = MediumA,
        designAirFlow=0.75,
        minAirFlow=0.2*0.75,
        designHeatingCapacity=7000,
        maxAirFlowHeat=0.5*0.75,
        sensitivityGainCool=0.75,
        sensitivityGainHeat=0.25,
        designHeatingEfficiency=0.99,
        designCoolingCOP=3,
        supplyAirTempSet=286.15,
        designCoolingCapacity=3000,
        dxCoilPerformance(sta={
              Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.Stage(
                  spe=1,
                  nomVal=
                Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.NominalValues(
                    Q_flow_nominal=-3000,
                    COP_nominal=3,
                    SHR_nominal=0.8,
                    m_flow_nominal=0.75),
                  perCur=dxCoilPerformanceCurve)}))
        annotation (Placement(transformation(extent={{-40,-10},{0,22}})));
      ThermalEnvelope.SingleZoneAirHVAC singleZoneAirHVAC(designAirFlow=0.75,
          lat=0.69359384474255)
        annotation (Placement(transformation(extent={{32,-4},{52,16}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=
            "modelica://Buildings/Resources/weatherdata/USA_CO_Golden-NREL.724666_TMY3.mos")
        annotation (Placement(transformation(extent={{-100,80},{-80,100}})));
      Buildings.Fluid.HeatExchangers.DXCoils.Examples.PerformanceCurves.Curve_II
        dxCoilPerformanceCurve
        annotation (Placement(transformation(extent={{60,82},{80,102}})));
    equation
      connect(weaDat.weaBus, singleZoneAirHVAC.weaBus) annotation (Line(
          points={{-80,90},{-26,90},{33,90},{33,16.6}},
          color={255,204,51},
          thickness=0.5));
      connect(vAV_SingleZone.returnAir[1], singleZoneAirHVAC.returnAir)
        annotation (Line(points={{0,0},{24,0},{24,22},{46.6,22},{46.6,16.7}},
            color={0,127,255}));
      connect(vAV_SingleZone.supplyAir, singleZoneAirHVAC.supplyAir)
        annotation (Line(points={{0,11.2},{4,11.2},{4,10},{14,10},{14,28},{37.8,
              28},{37.8,16.7}},      color={0,127,255}));
      connect(singleZoneAirHVAC.zoneMeanAirTemperature, vAV_SingleZone.Tmea)
        annotation (Line(points={{53,6},{60,6},{70,6},{70,-22},{-64,-22},{-64,6},
              {-42,6}},         color={0,0,127}));
      connect(singleZoneAirHVAC.TcoolSetpoint, vAV_SingleZone.TcoolSetpoint)
        annotation (Line(points={{53,-2},{62,-2},{62,-18},{-60,-18},{-60,13.8},
              {-42,13.8}}, color={0,0,127}));
      connect(singleZoneAirHVAC.TheatSetpoint, vAV_SingleZone.TheatSetpoint)
        annotation (Line(points={{53,0},{66,0},{66,-6},{-52,-6},{-52,19},{-42,
              19}}, color={0,0,127}));
      connect(weaDat.weaBus, vAV_SingleZone.weaBus) annotation (Line(
          points={{-80,90},{-37,90},{-37,23}},
          color={255,204,51},
          thickness=0.5));
      annotation (
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_GPC36_dxCoil;

    model VAV_SingleZone_GPC36_dxCoil_fan "Example for SingleZoneVAV"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      HVACSystems.VAV_SingleZone_GPC36_dxCoil_fan
                                 vAV_SingleZone(
        redeclare package Medium = MediumA,
        designHeatingCapacity=7000,
        sensitivityGainCool=0.75,
        sensitivityGainHeat=0.25,
        designHeatingEfficiency=0.99,
        designCoolingCOP=3,
        designAirFlow=1.0,
        minAirFlow=0.2*1.0,
        maxAirFlowHeat=0.5*1.0,
        designCoolingCapacity=8000,
        dxCoilPerformance(sta={
              Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.Stage(
                  spe=1,
                  nomVal=
                Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.NominalValues(
                    Q_flow_nominal=-8000,
                    COP_nominal=3,
                    SHR_nominal=0.8,
                    m_flow_nominal=1.0),
                  perCur=dxCoilPerformanceCurve)}),
        supplyAirTempSet=286.15)
        annotation (Placement(transformation(extent={{-40,-10},{0,22}})));
      ThermalEnvelope.Case610_AirHVAC   singleZoneAirHVAC(designAirFlow=1.0,
          lat=weaDat.lat)
        annotation (Placement(transformation(extent={{32,-4},{52,16}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=
            "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos")
        annotation (Placement(transformation(extent={{-100,80},{-80,100}})));
      Buildings.Fluid.HeatExchangers.DXCoils.Examples.PerformanceCurves.Curve_II
        dxCoilPerformanceCurve
        annotation (Placement(transformation(extent={{60,82},{80,102}})));
    equation
      connect(weaDat.weaBus, singleZoneAirHVAC.weaBus) annotation (Line(
          points={{-80,90},{-26,90},{33,90},{33,16.4}},
          color={255,204,51},
          thickness=0.5));
      connect(vAV_SingleZone.returnAir[1], singleZoneAirHVAC.returnAir)
        annotation (Line(points={{0,0},{24,0},{24,22},{44,22},{44,17}},
            color={0,127,255}));
      connect(vAV_SingleZone.supplyAir, singleZoneAirHVAC.supplyAir)
        annotation (Line(points={{0,11.2},{4,11.2},{4,10},{14,10},{14,28},{38,
              28},{38,17}},          color={0,127,255}));
      connect(singleZoneAirHVAC.zoneMeanAirTemperature, vAV_SingleZone.Tmea)
        annotation (Line(points={{53,6},{60,6},{70,6},{70,-22},{-64,-22},{-64,6},
              {-42,6}},         color={0,0,127}));
      connect(singleZoneAirHVAC.TcoolSetpoint, vAV_SingleZone.TcoolSetpoint)
        annotation (Line(points={{53,-2},{62,-2},{62,-18},{-60,-18},{-60,13.8},
              {-42,13.8}}, color={0,0,127}));
      connect(singleZoneAirHVAC.TheatSetpoint, vAV_SingleZone.TheatSetpoint)
        annotation (Line(points={{53,0},{66,0},{66,-6},{-52,-6},{-52,19},{-42,
              19}}, color={0,0,127}));
      connect(weaDat.weaBus, vAV_SingleZone.weaBus) annotation (Line(
          points={{-80,90},{-37,90},{-37,23}},
          color={255,204,51},
          thickness=0.5));
      annotation (
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_GPC36_dxCoil_fan;

    model VAV_SingleZone_GPC36_uCoils_fan "Example for SingleZoneVAV"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      HVACSystems.VAV_SingleZone_GPC36_uCoils_fan
                                 vAV_SingleZone(
        redeclare package Medium = MediumA,
        designAirFlow=0.75,
        minAirFlow=0.2*0.75,
        designCoolingCapacity=5000,
        designHeatingCapacity=7000,
        maxAirFlowHeat=0.5*0.75,
        sensitivityGainCool=0.75,
        sensitivityGainHeat=0.25,
        supplyAirTempSet=286.15,
        designHeatingEfficiency=0.99,
        designCoolingCOP=3)
        annotation (Placement(transformation(extent={{-40,-10},{0,22}})));
      ThermalEnvelope.SingleZoneAirHVAC singleZoneAirHVAC(designAirFlow=0.75,
          lat=0.69359384474255)
        annotation (Placement(transformation(extent={{32,-4},{52,16}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=
            "modelica://Buildings/Resources/weatherdata/USA_CO_Golden-NREL.724666_TMY3.mos")
        annotation (Placement(transformation(extent={{-100,80},{-80,100}})));
    equation
      connect(weaDat.weaBus, singleZoneAirHVAC.weaBus) annotation (Line(
          points={{-80,90},{-26,90},{33,90},{33,16.6}},
          color={255,204,51},
          thickness=0.5));
      connect(vAV_SingleZone.returnAir[1], singleZoneAirHVAC.returnAir)
        annotation (Line(points={{0,0},{24,0},{24,22},{46.6,22},{46.6,16.7}},
            color={0,127,255}));
      connect(vAV_SingleZone.supplyAir, singleZoneAirHVAC.supplyAir)
        annotation (Line(points={{0,11.2},{4,11.2},{4,10},{14,10},{14,28},{37.8,
              28},{37.8,16.7}},      color={0,127,255}));
      connect(singleZoneAirHVAC.zoneMeanAirTemperature, vAV_SingleZone.Tmea)
        annotation (Line(points={{53,6},{60,6},{70,6},{70,-22},{-64,-22},{-64,6},
              {-42,6}},         color={0,0,127}));
      connect(singleZoneAirHVAC.TcoolSetpoint, vAV_SingleZone.TcoolSetpoint)
        annotation (Line(points={{53,-2},{62,-2},{62,-18},{-60,-18},{-60,13.8},
              {-42,13.8}}, color={0,0,127}));
      connect(singleZoneAirHVAC.TheatSetpoint, vAV_SingleZone.TheatSetpoint)
        annotation (Line(points={{53,0},{66,0},{66,-6},{-52,-6},{-52,19},{-42,
              19}}, color={0,0,127}));
      connect(weaDat.weaBus, vAV_SingleZone.weaBus) annotation (Line(
          points={{-80,90},{-37,90},{-37,23}},
          color={255,204,51},
          thickness=0.5));
      annotation (
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_GPC36_uCoils_fan;

    model VAV_SingleZone_GPC36_uCoils_fan_mix "Example for SingleZoneVAV"
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      HVACSystems.VAV_SingleZone_GPC36_uCoils_fan_mix vAV_SingleZone(
        redeclare package Medium = MediumA,
        designAirFlow=0.75,
        minAirFlow=0.2*0.75,
        sensitivityGainCool=0.75,
        designCoolingCapacity=7000,
        designHeatingEfficiency=0.99,
        designCoolingCOP=3,
        sensitivityGainHeat=0.1,
        designHeatingCapacity=7000,
        minOAFlow=0.2*0.75,
        maxAirFlowHeat=0.5*0.75,
        dxCoilPerformance(sta={
              Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.Stage(
                  spe=1,
                  nomVal=
                Buildings.Fluid.HeatExchangers.DXCoils.Data.Generic.BaseClasses.NominalValues(
                    Q_flow_nominal=-7000,
                    COP_nominal=3,
                    SHR_nominal=0.8,
                    m_flow_nominal=0.75),
                  perCur=dxCoilPerformanceCurve)}),
        supplyAirTempSet=286.15)
        annotation (Placement(transformation(extent={{-40,-10},{0,22}})));
      ThermalEnvelope.Case610_NoInf_AirHVAC
                                        singleZoneAirHVAC(
          designAirFlow=0.75, lat=weaDat.lat)
        annotation (Placement(transformation(extent={{32,-4},{52,16}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=
            "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos")
        annotation (Placement(transformation(extent={{-100,80},{-80,100}})));
      Buildings.Fluid.HeatExchangers.DXCoils.Examples.PerformanceCurves.Curve_II
        dxCoilPerformanceCurve
        annotation (Placement(transformation(extent={{60,80},{80,100}})));
    equation
      connect(weaDat.weaBus, singleZoneAirHVAC.weaBus) annotation (Line(
          points={{-80,90},{-26,90},{33,90},{33,16.4}},
          color={255,204,51},
          thickness=0.5));
      connect(vAV_SingleZone.supplyAir, singleZoneAirHVAC.supplyAir)
        annotation (Line(points={{0,11.2},{4,11.2},{4,10},{14,10},{14,28},{38,
              28},{38,17}},          color={0,127,255}));
      connect(singleZoneAirHVAC.zoneMeanAirTemperature, vAV_SingleZone.Tmea)
        annotation (Line(points={{53,6},{60,6},{70,6},{70,-20},{-64,-20},{-64,6},
              {-42,6}},         color={0,0,127}));
      connect(singleZoneAirHVAC.TcoolSetpoint, vAV_SingleZone.TcoolSetpoint)
        annotation (Line(points={{53,-2},{62,-2},{62,-18},{-60,-18},{-60,13.8},
              {-42,13.8}}, color={0,0,127}));
      connect(singleZoneAirHVAC.TheatSetpoint, vAV_SingleZone.TheatSetpoint)
        annotation (Line(points={{53,0},{64,0},{64,-16},{-54,-16},{-54,19},{-42,
              19}}, color={0,0,127}));
      connect(singleZoneAirHVAC.returnAir, vAV_SingleZone.returnAir[1])
        annotation (Line(points={{44,17},{44,24},{18,24},{18,0},{0,0}}, color={
              0,127,255}));
      connect(weaDat.weaBus, vAV_SingleZone.weaBus) annotation (Line(
          points={{-80,90},{-37,90},{-37,23}},
          color={255,204,51},
          thickness=0.5));
      annotation (
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_GPC36_uCoils_fan_mix;

    model FreeFloat_SingleZone_2
      ThermalEnvelope.Case610_IdealAirHVAC   singleZoneUncontrolled(lat=weaDat.lat)
        annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=
            "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos")
        annotation (Placement(transformation(extent={{-60,20},{-40,40}})));
      Buildings.Fluid.Sources.MassFlowSource_T sinInf(
        use_T_in=false,
        use_X_in=false,
        use_C_in=false,
        nPorts=1,
        use_m_flow_in=false,
        m_flow=2,
        redeclare package Medium = Buildings.Media.Air)
                  "Sink model for air infiltration"
        annotation (Placement(transformation(extent={{-34,48},{-22,60}})));
    equation
      connect(weaDat.weaBus, singleZoneUncontrolled.weaBus) annotation (Line(
          points={{-40,30},{-9,30},{-9,10.4}},
          color={255,204,51},
          thickness=0.5));
      connect(sinInf.ports[1], singleZoneUncontrolled.supplyAirCool)
        annotation (Line(points={{-22,54},{0,54},{0,11}},   color={0,127,255}));
      annotation (
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          __Dymola_Algorithm="Radau"));
    end FreeFloat_SingleZone_2;
  end Examples;
  annotation (uses(Modelica(version="3.2.2"), Buildings(version="4.0.0")));
end SOEPDemo;
