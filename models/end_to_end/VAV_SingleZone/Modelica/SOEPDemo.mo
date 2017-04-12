within ;
package SOEPDemo
  "Package containing models for SOEP demonstration and EnergyPlus comparison."

  package ThermalEnvelope
    "Package containing models for the thermal envelope of the building"

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
        extConMod=Buildings.HeatTransfer.Types.ExteriorConvection.TemperatureWind,
        steadyStateWindow=false)
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
      Buildings.Fluid.Movers.BaseClasses.IdealSource infMover(
        control_m_flow=true,
        allowFlowReversal=false,
        redeclare package Medium = MediumA,
        m_flow_small=1e-4)
        annotation (Placement(transformation(extent={{-38,-38},{-30,-30}})));
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

      connect(sinInf.ports[1], roo.ports[2]) annotation (Line(points={{-12,-20},
              {14,-20},{14,-22.5},{15.75,-22.5}},
                                              color={0,127,255}));
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
      connect(souInf.ports[1], infMover.port_a)
        annotation (Line(points={{-52,-34},{-38,-34}}, color={0,127,255}));
      connect(infMover.port_b, roo.ports[3]) annotation (Line(points={{-30,-34},
              {-6,-34},{-6,-24},{-6,-20.5},{15.75,-20.5}}, color={0,127,255}));
      connect(product.y, infMover.m_flow_in) annotation (Line(points={{-39.5,
              -55},{-34,-55},{-34,-44},{-44,-44},{-44,-26},{-36.4,-26},{-36.4,
              -30.8}}, color={0,0,127}));
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

    model Case600FF_IntLoad
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
        extConMod=Buildings.HeatTransfer.Types.ExteriorConvection.TemperatureWind,
        steadyStateWindow=false)
        "Room model for Case 600"
        annotation (Placement(transformation(extent={{12,-30},{42,0}})));
      Modelica.Blocks.Sources.Constant qConGai_flow(k=192/48)
                                                             "Convective heat gain"
        annotation (Placement(transformation(extent={{-78,-6},{-70,2}})));
      Modelica.Blocks.Sources.Constant qRadGai_flow(k=288/48) "Radiative heat gain"
        annotation (Placement(transformation(extent={{-66,6},{-58,14}})));
      Modelica.Blocks.Routing.Multiplex3 multiplex3_1
        annotation (Placement(transformation(extent={{-32,-6},{-24,2}})));
      Modelica.Blocks.Sources.Constant qLatGai_flow(k=96/48)
                                                         "Latent heat gain"
        annotation (Placement(transformation(extent={{-66,-16},{-58,-8}})));
      Modelica.Blocks.Sources.Constant uSha(k=0)
        "Control signal for the shading device"
        annotation (Placement(transformation(extent={{-44,14},{-36,22}})));
      Modelica.Blocks.Routing.Replicator replicator(nout=max(1,nConExtWin))
        annotation (Placement(transformation(extent={{-28,14},{-20,22}})));
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
      Buildings.Fluid.Movers.BaseClasses.IdealSource infMover(
        control_m_flow=true,
        allowFlowReversal=false,
        redeclare package Medium = MediumA,
        m_flow_small=1e-4)
        annotation (Placement(transformation(extent={{-38,-38},{-30,-30}})));
      Schedules.IntLoad intLoad
        annotation (Placement(transformation(extent={{-80,12},{-72,20}})));
      Modelica.Blocks.Math.Product product1
        annotation (Placement(transformation(extent={{-52,4},{-44,12}})));
      Modelica.Blocks.Math.Product product2
        annotation (Placement(transformation(extent={{-52,-18},{-44,-10}})));
      Modelica.Blocks.Math.Product product3
        annotation (Placement(transformation(extent={{-52,-6},{-44,2}})));
    equation
      connect(multiplex3_1.y, roo.qGai_flow) annotation (Line(
          points={{-23.6,-2},{-22,-2},{-22,-9},{10.8,-9}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(roo.uSha, replicator.y) annotation (Line(
          points={{10.8,-1.5},{-18,-1.5},{-18,18},{-19.6,18}},
          color={0,0,127},
          smooth=Smooth.None));
      connect(uSha.y, replicator.u) annotation (Line(
          points={{-35.6,18},{-34,18},{-34,18},{-30,18},{-30,18},{-28.8,18}},
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

      connect(sinInf.ports[1], roo.ports[2]) annotation (Line(points={{-12,-20},
              {14,-20},{14,-22.5},{15.75,-22.5}},
                                              color={0,127,255}));
      connect(weaBus,sinInf. weaBus) annotation (Line(
          points={{-90,104},{-90,104},{-90,-20},{-24,-20},{-24,-19.88}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));
      connect(weaBus, roo.weaBus) annotation (Line(
          points={{-90,104},{-90,104},{-90,24},{40,24},{40,2},{40.425,2},{
              40.425,-1.575}},
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
      connect(souInf.ports[1], infMover.port_a)
        annotation (Line(points={{-52,-34},{-38,-34}}, color={0,127,255}));
      connect(infMover.port_b, roo.ports[3]) annotation (Line(points={{-30,-34},
              {-6,-34},{-6,-24},{-6,-20.5},{15.75,-20.5}}, color={0,127,255}));
      connect(product.y, infMover.m_flow_in) annotation (Line(points={{-39.5,
              -55},{-34,-55},{-34,-44},{-44,-44},{-44,-26},{-36.4,-26},{-36.4,
              -30.8}}, color={0,0,127}));
      connect(qRadGai_flow.y, product1.u1) annotation (Line(points={{-57.6,10},
              {-52.8,10},{-52.8,10.4}}, color={0,0,127}));
      connect(qLatGai_flow.y, product2.u1) annotation (Line(points={{-57.6,-12},
              {-52.8,-12},{-52.8,-11.6}}, color={0,0,127}));
      connect(qConGai_flow.y, product3.u1) annotation (Line(points={{-69.6,-2},
              {-62,-2},{-62,0.4},{-52.8,0.4}}, color={0,0,127}));
      connect(intLoad.y[1], product2.u2) annotation (Line(points={{-71.6,16},{
              -56,16},{-56,-16.4},{-52.8,-16.4}}, color={0,0,127}));
      connect(product3.u2, product2.u2) annotation (Line(points={{-52.8,-4.4},{
              -56,-4.4},{-56,-16.4},{-52.8,-16.4}}, color={0,0,127}));
      connect(product1.u2, product2.u2) annotation (Line(points={{-52.8,5.6},{
              -56,5.6},{-56,-16.4},{-52.8,-16.4}}, color={0,0,127}));
      connect(product1.y, multiplex3_1.u1[1]) annotation (Line(points={{-43.6,8},
              {-36,8},{-36,0.8},{-32.8,0.8}}, color={0,0,127}));
      connect(product3.y, multiplex3_1.u2[1]) annotation (Line(points={{-43.6,
              -2},{-32.8,-2},{-32.8,-2}}, color={0,0,127}));
      connect(product2.y, multiplex3_1.u3[1]) annotation (Line(points={{-43.6,
              -14},{-36,-14},{-36,-4.8},{-32.8,-4.8}}, color={0,0,127}));
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
    end Case600FF_IntLoad;

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
      extends Case600FF_IntLoad(roo(nPorts=6));
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
      Buildings.Fluid.Sensors.MassFlowRate supplyAirFlow(redeclare package
          Medium =
            MediumA, allowFlowReversal=false)
        annotation (Placement(transformation(extent={{-56,38},{-36,58}})));
      Buildings.Fluid.Sensors.MassFlowRate returnAirFlow(redeclare package
          Medium =
            MediumA, allowFlowReversal=false)
        annotation (Placement(transformation(extent={{0,58},{-20,78}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort supplyAirTemp(redeclare
          package Medium =
                   MediumA, m_flow_nominal=designAirFlow,
        allowFlowReversal=false,
        tau=0)
        annotation (Placement(transformation(extent={{-28,38},{-8,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort returnAirTemp(redeclare
          package Medium =
                   MediumA, m_flow_nominal=designAirFlow,
        allowFlowReversal=false,
        tau=0)
        annotation (Placement(transformation(extent={{28,58},{8,78}})));
      Schedules.TSetCoo tSetCoo
        annotation (Placement(transformation(extent={{60,-90},{80,-70}})));
      Schedules.TSetHea tSetHea
        annotation (Placement(transformation(extent={{60,-60},{80,-40}})));
      Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heaPorAir
        "Heat port to air volume"
        annotation (Placement(transformation(extent={{60,0},{80,20}})));
    equation
      connect(supplyAir, supplyAirFlow.port_a)
        annotation (Line(points={{-60,100},{-60,48},{-56,48}}, color={0,127,255}));
      connect(supplyAirFlow.port_b, supplyAirTemp.port_a)
        annotation (Line(points={{-36,48},{-28,48}}, color={0,127,255}));
      connect(supplyAirTemp.port_b, roo.ports[4]) annotation (Line(points={{-8,48},{
              -8,48},{-8,-18},{-8,-22.5},{15.75,-22.5}}, color={0,127,255}));
      connect(returnAirFlow.port_b, returnAir) annotation (Line(points={{-20,68},
              {-30,68},{-30,100}}, color={0,127,255}));
      connect(returnAirFlow.port_a, returnAirTemp.port_b)
        annotation (Line(points={{0,68},{4,68},{8,68}}, color={0,127,255}));
      connect(returnAirTemp.port_a, roo.ports[5]) annotation (Line(points={{28,
              68},{32,68},{34,68},{34,10},{4,10},{4,-22.5},{15.75,-22.5}},
            color={0,127,255}));
      connect(tSetCoo.y[1], TcoolSetpoint) annotation (Line(points={{81,-80},{
              110,-80},{110,-80}}, color={0,0,127}));
      connect(tSetHea.y[1], TheatSetpoint) annotation (Line(points={{81,-50},{
              90,-50},{90,-60},{110,-60}}, color={0,0,127}));
      connect(roo.heaPorAir, heaPorAir) annotation (Line(points={{26.25,-15},{
              38.125,-15},{38.125,10},{70,10}}, color={191,0,0}));
    end Case600_AirHVAC;

    block FMI_Case600_AirHVAC
      extends Buildings.Fluid.FMI.ExportContainers.ThermalZone;
      parameter String filNam = "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos" "File name of weather file.";
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design air mass flow rate";
      Case600_AirHVAC case600_AirHVAC(lat=weaDat.lat, designAirFlow=designAirFlow)
        annotation (Placement(transformation(extent={{-10,-8},{10,12}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=filNam)
        annotation (Placement(transformation(extent={{-140,60},{-120,80}})));
    equation
      connect(case600_AirHVAC.supplyAir, theZonAda.ports[1]) annotation (Line(
            points={{-4,13},{-4,13},{-4,150},{-4,160},{-120,160}}, color={0,127,255}));
      connect(case600_AirHVAC.returnAir, theZonAda.ports[2]) annotation (Line(
            points={{2,13},{2,13},{2,156},{-120,156},{-120,160}}, color={0,127,255}));
      connect(theZonAda.heaPorAir, case600_AirHVAC.heaPorAir) annotation (Line(
            points={{-120,152},{6,152},{6,4},{6,3},{7,3}},       color={191,0,0}));
      connect(weaDat.weaBus, case600_AirHVAC.weaBus) annotation (Line(
          points={{-120,70},{-76,70},{-9,70},{-9,12.4}},
          color={255,204,51},
          thickness=0.5));
    end FMI_Case600_AirHVAC;

    block FMI_Case600_AirHVAC_TOnly
      extends Buildings.Fluid.FMI.ExportContainers.ThermalZone;
      parameter String filNam = "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos" "File name of weather file.";
      Buildings.Fluid.Sources.FixedBoundary sin(redeclare package Medium =
            Buildings.Media.Air, nPorts=1)
        annotation (Placement(transformation(extent={{0,150},{-20,170}})));
      Buildings.Fluid.Sources.Boundary_pT bou(redeclare package Medium =
            Buildings.Media.Air, use_T_in=true,
        nPorts=1,
        use_X_in=true)
        annotation (Placement(transformation(extent={{0,110},{-20,130}})));
      Buildings.Fluid.Sensors.MassFlowRate senMasFlo(redeclare package Medium =
            Buildings.Media.Air)
        annotation (Placement(transformation(extent={{-80,150},{-60,170}})));
      Buildings.Fluid.Sensors.MassFlowRate senMasFlo1(redeclare package Medium =
            Buildings.Media.Air)
        annotation (Placement(transformation(extent={{-80,110},{-60,130}})));
      Modelica.Blocks.Sources.CombiTimeTable combiTimeTable(
        tableOnFile=true,
        tableName="tab",
        fileName="/home/dhblum/ThermalZone_T.txt",
        columns=2:3)
        annotation (Placement(transformation(extent={{50,114},{30,134}})));
      Buildings.HeatTransfer.Sources.PrescribedTemperature
        prescribedTemperature
        annotation (Placement(transformation(extent={{-60,80},{-80,100}})));
      Modelica.Blocks.Sources.Constant const(k=1)
        annotation (Placement(transformation(extent={{60,50},{40,70}})));
      Modelica.Blocks.Math.Add add(k2=-1)
        annotation (Placement(transformation(extent={{8,40},{-12,60}})));
    equation
      connect(theZonAda.ports[1], senMasFlo.port_a) annotation (Line(points={{-120,160},
              {-100,160},{-80,160}}, color={0,127,255}));
      connect(senMasFlo.port_b, sin.ports[1]) annotation (Line(points={{-60,160},{-40,
              160},{-20,160}}, color={0,127,255}));
      connect(bou.ports[1], senMasFlo1.port_b) annotation (Line(points={{-20,120},{-40,
              120},{-60,120}}, color={0,127,255}));
      connect(senMasFlo1.port_a, theZonAda.ports[2]) annotation (Line(points={{-80,120},
              {-104,120},{-104,160},{-120,160}}, color={0,127,255}));
      connect(prescribedTemperature.port, theZonAda.heaPorAir) annotation (Line(
            points={{-80,90},{-94,90},{-110,90},{-110,152},{-120,152}}, color={
              191,0,0}));
      connect(combiTimeTable.y[2], bou.T_in)
        annotation (Line(points={{29,124},{2,124}}, color={0,0,127}));
      connect(combiTimeTable.y[1], bou.X_in[1]) annotation (Line(points={{29,
              124},{16,124},{16,116},{2,116}}, color={0,0,127}));
      connect(combiTimeTable.y[2], prescribedTemperature.T) annotation (Line(
            points={{29,124},{16,124},{16,90},{-58,90}}, color={0,0,127}));
      connect(const.y, add.u1) annotation (Line(points={{39,60},{26,60},{26,56},
              {10,56}}, color={0,0,127}));
      connect(add.y, bou.X_in[2]) annotation (Line(points={{-13,50},{-18,50},{
              -18,70},{8,70},{8,102},{8,102},{8,116},{2,116}}, color={0,0,127}));
      connect(combiTimeTable.y[1], add.u2) annotation (Line(points={{29,124},{
              22,124},{22,44},{10,44}}, color={0,0,127}));
    end FMI_Case600_AirHVAC_TOnly;
  end ThermalEnvelope;

  package Schedules "Package containing schedules"

    model TSetCoo "Schedule of cooling setpoint temperature"
      extends Modelica.Blocks.Sources.CombiTimeTable(
        extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
        table=[0,30+273.15; 8*3600,30+273.15; 8*3600,25+273.15; 18*3600,25+273.15; 18*3600,30+273.15; 24*3600,30+273.15],
        columns={2});
    end TSetCoo;

    model TSetHea "Schedule of heating setpoint temperature"
      extends Modelica.Blocks.Sources.CombiTimeTable(
        extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
        table=[0,15+273.15; 8*3600,15+273.15; 8*3600,20+273.15; 18*3600,20+273.15; 18*3600,15+273.15; 24*3600,15+273.15],
        columns={2});
    end TSetHea;

    model IntLoad "Schedule for time varying internal loads"
      extends Modelica.Blocks.Sources.CombiTimeTable(
        extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
        table=[0,0.1; 8*3600,0.1; 8*3600,1.0; 18*3600,1.0; 18*3600,0.1; 24*3600,0.1],
        columns={2});
    end IntLoad;
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
      parameter Real sensitivityGainHeat(unit="K") =  1 "Gain sensitivity on heating controller";
      parameter Real sensitivityGainCool(unit="K") =  0.3 "Gain sensitivity on cooling controller";
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
        tau=30) "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{110,38},{130,58}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u heatCoil(
        m_flow_nominal=designAirFlow,
        redeclare package Medium = Medium,
        Q_flow_nominal=designHeatingCapacity,
        u(start=0),
        dp_nominal=0,
        tau=90) "Air heating coil"
        annotation (Placement(transformation(extent={{76,38},{96,58}})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation (Placement(
            transformation(extent={{-190,148},{-150,188}}), iconTransformation(
              extent={{-180,160},{-160,180}})));
      Buildings.Fluid.HeatExchangers.DXCoils.AirCooled.SingleSpeed
                                                         dxCoilSingle(
        datCoi=dxCoilPerformance,
        redeclare package Medium = Medium,
        dp_nominal=0,
        tau=90) annotation (Placement(transformation(extent={{36,38},{56,58}})));
      parameter Buildings.Fluid.HeatExchangers.DXCoils.AirCooled.Data.Generic.DXCoil
        dxCoilPerformance(nSta=1,
        minSpeRat=0,
        sta={
            Buildings.Fluid.HeatExchangers.DXCoils.AirCooled.Data.Generic.BaseClasses.Stage(
                spe=1,
                nomVal=
              Buildings.Fluid.HeatExchangers.DXCoils.AirCooled.Data.Generic.BaseClasses.NominalValues(
                  Q_flow_nominal=-designCoolingCapacity,
                  COP_nominal=designCoolingCOP,
                  SHR_nominal=0.8,
                  m_flow_nominal=0.75),
                perCur=dxCoilPerformanceCurve)})
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
      parameter Modelica.SIunits.DimensionlessRatio oaFraction "Outside air fraction";
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
      Buildings.Fluid.Sensors.MassFlowRate exhaustAirFlow(redeclare package Medium =
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
          package
          Medium = Medium, m_flow_nominal=designAirFlow)
        "Mixed air temperature sensor"
        annotation (Placement(transformation(extent={{70,-70},{90,-50}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u coolCoil(
        m_flow_nominal=designAirFlow,
        redeclare package Medium = Medium,
        u(start=0),
        dp_nominal=0,
        Q_flow_nominal=designCoolingCapacity) "Air cooling coil"
        annotation (Placement(transformation(extent={{80,38},{100,58}})));
      Buildings.Fluid.Sensors.MassFlowRate returnAirFlow(redeclare package Medium =
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
      Buildings.Fluid.Movers.BaseClasses.IdealSource idealSourceExhaust(
        redeclare package Medium = Medium,
        control_m_flow=true,
        m_flow_small=1e-4)
        annotation (Placement(transformation(extent={{30,-70},{10,-50}})));
      Buildings.Fluid.Movers.BaseClasses.IdealSource idealSourceRelief(
        redeclare package Medium = Medium,
        control_m_flow=true,
        m_flow_small=1E-4)
        annotation (Placement(transformation(extent={{-80,-70},{-100,-50}})));
      Modelica.Blocks.Math.Gain fraction(k=oaFraction) annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=0,
            origin={-42,-40})));
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
        annotation (Line(points={{-90,48},{-120,48},{-120,48}},
                                                      color={0,127,255}));
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
      connect(returnAirFlow.port_a, exhaustAirFlow.port_a) annotation (Line(points={
              {-60,-20},{-60,-20},{-60,-60},{-30,-60}}, color={0,127,255}));
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
      connect(idealSourceRelief.port_a, exhaustAirFlow.port_a)
        annotation (Line(points={{-80,-60},{-30,-60}}, color={0,127,255}));
      connect(idealSourceRelief.port_b, out.ports[2]) annotation (Line(points={{-100,
              -60},{-106,-60},{-106,44},{-120,44}}, color={0,127,255}));
      connect(exhaustAirFlow.m_flow, fraction.u)
        annotation (Line(points={{-20,-49},{-20,-40},{-30,-40}}, color={0,0,127}));
      connect(fraction.y, idealSourceRelief.m_flow_in)
        annotation (Line(points={{-53,-40},{-84,-40},{-84,-52}}, color={0,0,127}));
      connect(exhaustAirFlow.port_b, idealSourceExhaust.port_b)
        annotation (Line(points={{-10,-60},{10,-60}}, color={0,127,255}));
      connect(idealSourceExhaust.port_a, returnAirTemp.port_a)
        annotation (Line(points={{30,-60},{70,-60}}, color={0,127,255}));
      connect(control.fanSet, idealSourceExhaust.m_flow_in) annotation (Line(points=
             {{-119,4},{-66,4},{26,4},{26,-52}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},
                {200,160}})),                                        Diagram(
            coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},{200,160}})),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_uCoils_fan_mix;

    model VAV_SingleZone_dxCoilSingle_fan_mix
      "HVAC system model with a single speed air-cooled DX coil, electric heating coil, variable speed fan, and mixing box."
      replaceable package Medium =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component"
          annotation (choicesAllMatching = true);
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Modelica.SIunits.DimensionlessRatio oaFraction "Minimum airflow rate of system";
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
        annotation (Placement(transformation(extent={{190,-20},{210,60}}),
            iconTransformation(extent={{190,-20},{210,60}})));
      Modelica.Fluid.Interfaces.FluidPorts_b returnAir[1](redeclare package
          Medium = Medium)                               "Return air"
        annotation (Placement(transformation(extent={{190,-140},{210,-60}}),
            iconTransformation(extent={{190,-140},{210,-60}})));
      Modelica.Blocks.Interfaces.RealInput TheatSetpoint
        "Zone heating setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,140})));
      Modelica.Blocks.Interfaces.RealInput TcoolSetpoint
        "Zone cooling setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,80})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          supplyAirTemp(redeclare package
          Medium =
            Medium, m_flow_nominal=designAirFlow,
        allowFlowReversal=false,
        tau=0)  "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{128,38},{148,58}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u heatCoil(
        m_flow_nominal=designAirFlow,
        redeclare package Medium = Medium,
        Q_flow_nominal=designHeatingCapacity,
        u(start=0),
        dp_nominal=0,
        allowFlowReversal=false,
        tau=90) "Air heating coil"
        annotation (Placement(transformation(extent={{94,38},{114,58}})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation (Placement(
            transformation(extent={{-190,148},{-150,188}}), iconTransformation(
              extent={{-180,160},{-160,180}})));
      Buildings.Fluid.HeatExchangers.DXCoils.AirCooled.SingleSpeed
                                                         dxCoilSingle(
        datCoi=dxCoilPerformance,
        redeclare package Medium = Medium,
        dp_nominal=0,
        allowFlowReversal=false,
        tau=90) annotation (Placement(transformation(extent={{58,38},{78,58}})));
      parameter Buildings.Fluid.HeatExchangers.DXCoils.AirCooled.Data.Generic.DXCoil
        dxCoilPerformance(nSta=1, sta={
            Buildings.Fluid.HeatExchangers.DXCoils.AirCooled.Data.Generic.BaseClasses.Stage(
            spe=1,
            nomVal=
              Buildings.Fluid.HeatExchangers.DXCoils.AirCooled.Data.Generic.BaseClasses.NominalValues(
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
        nominalValuesDefineDefaultPressureCurve=true,
        dp_nominal=875,
        per(use_powerCharacteristic=false),
        energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
        allowFlowReversal=false,
        use_inputFilter=false)
        annotation (Placement(transformation(extent={{-32,38},{-12,58}})));
      Modelica.Blocks.Sources.Constant supplyAirTempSetConst(k=supplyAirTempSet)
        annotation (Placement(transformation(extent={{190,-18},{170,2}})));
      Control control(designAirFlow=designAirFlow, minAirFlow=minAirFlow,
        sensitivityGainHeat=sensitivityGainHeat,
        sensitivityGainCool=sensitivityGainCool)
        annotation (Placement(transformation(extent={{-140,0},{-120,20}})));
      Buildings.Fluid.FixedResistances.PressureDrop totalRes(
        m_flow_nominal=designAirFlow,
        dp_nominal=500,
        redeclare package Medium = Medium,
        allowFlowReversal=false)
        annotation (Placement(transformation(extent={{-2,38},{18,58}})));
      Modelica.Blocks.Interfaces.RealOutput fanPower
        "Electrical power consumed by the supply fan"
        annotation (Placement(transformation(extent={{200,130},{220,150}}),
            iconTransformation(extent={{200,130},{220,150}})));
      Modelica.Blocks.Interfaces.RealOutput heatPower
        "Electrical power consumed by the heating equipment" annotation (
          Placement(transformation(extent={{200,110},{220,130}}),
            iconTransformation(extent={{200,110},{220,130}})));
      Modelica.Blocks.Interfaces.RealOutput coolPower
        "Electrical power consumed by the cooling equipment" annotation (
          Placement(transformation(extent={{200,90},{220,110}}),
            iconTransformation(extent={{200,90},{220,110}})));
      Modelica.Blocks.Logical.OnOffController onOffController(bandwidth=3)
        annotation (Placement(transformation(extent={{140,-20},{120,0}})));
      Modelica.Blocks.Logical.Not not1
        annotation (Placement(transformation(extent={{100,-20},{80,0}})));
      Modelica.Blocks.Logical.And and1
        annotation (Placement(transformation(extent={{20,0},{40,20}})));
      Modelica.Blocks.Math.Gain eff(k=1/designHeatingEfficiency)
        annotation (Placement(transformation(extent={{120,90},{140,110}})));
      Buildings.Fluid.Sensors.MassFlowRate returnAirFlow(redeclare package
          Medium =
            Medium, allowFlowReversal=false)
                    annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=90,
            origin={-66,-6})));
      Buildings.Fluid.Sensors.MassFlowRate exhaustAirFlow(redeclare package
          Medium =
            Medium, allowFlowReversal=false)
        annotation (Placement(transformation(extent={{-20,-70},{-40,-50}})));
      Buildings.Fluid.Sensors.MassFlowRate oaAirFlow(redeclare package Medium =
            Medium, allowFlowReversal=false)
        annotation (Placement(transformation(extent={{-100,38},{-80,58}})));
      Buildings.Fluid.Sources.Outside out(          redeclare package Medium =
            Medium, nPorts=2)
        annotation (Placement(transformation(extent={{-140,36},{-120,56}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort mixedAirTemp(
        redeclare package Medium = Medium,
        m_flow_nominal=designAirFlow,
        allowFlowReversal=false,
        tau=0)  "Mixed air temperature sensor"
        annotation (Placement(transformation(extent={{-60,38},{-40,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort freezeStat(
        redeclare package Medium = Medium,
        m_flow_nominal=designAirFlow,
        allowFlowReversal=false,
        tau=0)  "Temperature sensor to detect freezing conditions"
        annotation (Placement(transformation(extent={{24,38},{44,58}})));
      Modelica.Blocks.Math.Gain fraction(k=oaFraction) annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=0,
            origin={-50,-40})));
      Buildings.Fluid.Movers.BaseClasses.IdealSource idealSourceExhaust(
        redeclare package Medium = Medium,
        control_m_flow=true,
        allowFlowReversal=false,
        m_flow_small=1e-4)
        annotation (Placement(transformation(extent={{40,-70},{20,-50}})));
      Buildings.Fluid.Movers.BaseClasses.IdealSource idealSourceRelief(
        redeclare package Medium = Medium,
        control_m_flow=true,
        allowFlowReversal=false,
        m_flow_small=1E-4)
        annotation (Placement(transformation(extent={{-80,-70},{-100,-50}})));
      Modelica.Blocks.Logical.Hysteresis hysteresis(uLow=0.45, uHigh=0.55)
        annotation (Placement(transformation(extent={{-40,0},{-20,20}})));
    equation

      connect(supplyAirTemp.port_b, supplyAir) annotation (Line(points={{148,48},
              {200,48},{200,20}}, color={0,127,255}));
      connect(weaBus.TDryBul, dxCoilSingle.TConIn) annotation (Line(
          points={{-170,168},{-170,154},{52,154},{52,51},{57,51}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));
      connect(control.fanSet, supplyFan.m_flow_in) annotation (Line(points={{-119,4},
              {-98,4},{-98,80},{-22.2,80},{-22.2,60}}, color={0,0,127}));
      connect(TheatSetpoint, control.TheatSet) annotation (Line(points={{-220,
              140},{-160,140},{-160,17},{-141,17}},
                                              color={0,0,127}));
      connect(TcoolSetpoint, control.TcoolSet) annotation (Line(points={{-220,80},
              {-202,80},{-178,80},{-178,12},{-141,12}},
                                                  color={0,0,127}));
      connect(Tmea, control.Tmea) annotation (Line(points={{-220,0},{-181,0},{-181,2.8},
              {-141,2.8}}, color={0,0,127}));
      connect(supplyFan.port_b, totalRes.port_a)
        annotation (Line(points={{-12,48},{-2,48}},  color={0,127,255}));
      connect(supplyFan.P, fanPower) annotation (Line(points={{-11,56},{-6,56},
              {-6,140},{210,140}},
                                 color={0,0,127}));
      connect(dxCoilSingle.P, coolPower) annotation (Line(points={{79,57},{80,
              57},{80,100},{210,100}}, color={0,0,127}));
      connect(supplyAirTempSetConst.y, onOffController.reference) annotation (
          Line(points={{169,-8},{152,-8},{152,-4},{142,-4}}, color={0,0,127}));
      connect(supplyAirTemp.T, onOffController.u) annotation (Line(points={{138,59},
              {138,72},{152,72},{152,-16},{142,-16}},     color={0,0,127}));
      connect(onOffController.y, not1.u)
        annotation (Line(points={{119,-10},{102,-10}}, color={255,0,255}));
      connect(not1.y, and1.u2) annotation (Line(points={{79,-10},{32,-10},{-16,
              -10},{-16,2},{18,2}}, color={255,0,255}));
      connect(and1.y, dxCoilSingle.on) annotation (Line(points={{41,10},{54,10},
              {54,56},{57,56}}, color={255,0,255}));
      connect(eff.y, heatPower) annotation (Line(points={{141,100},{160,100},{
              160,120},{210,120}}, color={0,0,127}));
      connect(oaAirFlow.port_a, out.ports[1]) annotation (Line(points={{-100,48},
              {-110,48},{-110,48},{-120,48}},
                              color={0,127,255}));
      connect(weaBus, out.weaBus) annotation (Line(
          points={{-170,168},{-170,168},{-170,46},{-140,46},{-140,46.2}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));
      connect(mixedAirTemp.port_b, supplyFan.port_a)
        annotation (Line(points={{-40,48},{-40,48},{-32,48}}, color={0,127,255}));
      connect(oaAirFlow.port_b, mixedAirTemp.port_a)
        annotation (Line(points={{-80,48},{-70,48},{-60,48}}, color={0,127,255}));
      connect(returnAirFlow.port_b, mixedAirTemp.port_a)
        annotation (Line(points={{-66,4},{-66,48},{-60,48}}, color={0,127,255}));
      connect(fraction.u, exhaustAirFlow.m_flow) annotation (Line(points={{-38,
              -40},{-30,-40},{-30,-49}}, color={0,0,127}));
      connect(totalRes.port_b, freezeStat.port_a)
        annotation (Line(points={{18,48},{24,48}}, color={0,127,255}));
      connect(dxCoilSingle.port_b, heatCoil.port_a)
        annotation (Line(points={{78,48},{94,48}}, color={0,127,255}));
      connect(heatCoil.port_b, supplyAirTemp.port_a)
        annotation (Line(points={{114,48},{128,48}}, color={0,127,255}));
      connect(freezeStat.port_b, dxCoilSingle.port_a)
        annotation (Line(points={{44,48},{51,48},{58,48}}, color={0,127,255}));
      connect(heatCoil.Q_flow, eff.u) annotation (Line(points={{115,54},{120,54},
              {120,72},{108,72},{108,100},{118,100}}, color={0,0,127}));
      connect(control.heaterSet, heatCoil.u) annotation (Line(points={{-119,16},
              {-100,16},{-100,86},{86,86},{86,54},{92,54}}, color={0,0,127}));
      connect(idealSourceExhaust.m_flow_in, supplyFan.m_flow_in) annotation (
          Line(points={{36,-52},{36,-24},{-98,-24},{-98,80},{-22.2,80},{-22.2,
              60}}, color={0,0,127}));
      connect(idealSourceExhaust.port_a, returnAir[1]) annotation (Line(points={{40,-60},
              {200,-60},{200,-100}},          color={0,127,255}));
      connect(idealSourceExhaust.port_b, exhaustAirFlow.port_a) annotation (
          Line(points={{20,-60},{0,-60},{-20,-60}}, color={0,127,255}));
      connect(idealSourceRelief.port_a, exhaustAirFlow.port_b)
        annotation (Line(points={{-80,-60},{-40,-60}}, color={0,127,255}));
      connect(idealSourceRelief.port_b, out.ports[2]) annotation (Line(points={
              {-100,-60},{-106,-60},{-106,44},{-120,44}}, color={0,127,255}));
      connect(fraction.y, idealSourceRelief.m_flow_in) annotation (Line(points=
              {{-61,-40},{-84,-40},{-84,-52}}, color={0,0,127}));
      connect(returnAirFlow.port_a, exhaustAirFlow.port_b) annotation (Line(
            points={{-66,-16},{-66,-60},{-40,-60}}, color={0,127,255}));
      connect(hysteresis.y, and1.u1) annotation (Line(points={{-19,10},{-0.5,10},
              {18,10}}, color={255,0,255}));
      connect(hysteresis.u, control.coolSignal) annotation (Line(points={{-42,
              10},{-80,10},{-80,12},{-119,12}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},
                {200,160}}), graphics={
            Rectangle(
              extent={{-200,160},{-160,-160}},
              lineColor={0,0,0},
              fillColor={170,255,255},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-160,160},{200,-160}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{180,40},{-160,0}},
              lineColor={175,175,175},
              fillColor={175,175,175},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-32,36},{-4,22}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{180,-72},{-160,-112}},
              lineColor={175,175,175},
              fillColor={175,175,175},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-80,0},{-120,-72}},
              lineColor={175,175,175},
              fillColor={175,175,175},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-48,36},{-14,2}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-38,26},{-24,12}},
              lineColor={0,0,0},
              fillColor={0,0,0},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{40,40},{54,0}},
              lineColor={255,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Backward),
            Rectangle(
              extent={{102,40},{116,0}},
              lineColor={0,0,255},
              fillColor={255,255,255},
              fillPattern=FillPattern.Backward),
            Rectangle(
              extent={{42,54},{52,46}},
              lineColor={0,0,0},
              fillColor={0,0,0},
              fillPattern=FillPattern.Backward),
            Rectangle(
              extent={{38,56},{56,54}},
              lineColor={0,0,0},
              fillColor={0,0,0},
              fillPattern=FillPattern.Backward),
            Line(points={{44,56},{44,60}}, color={0,0,0}),
            Line(points={{50,56},{50,60}}, color={0,0,0}),
            Line(points={{48,40},{48,48}}, color={0,0,0}),
            Ellipse(
              extent={{84,54},{110,44}},
              lineColor={0,0,0},
              fillColor={95,95,95},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{110,54},{136,44}},
              lineColor={0,0,0},
              fillColor={95,95,95},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-140,40},{-126,0}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Backward),
            Rectangle(
              extent={{-140,-72},{-126,-112}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Backward),
            Rectangle(
              extent={{-7,20},{7,-20}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Backward,
              origin={-100,-37},
              rotation=90),
            Line(points={{-160,160},{-160,-160}}, color={0,0,0}),
            Line(points={{200,100},{108,100},{108,70}}, color={0,0,127}),
            Line(points={{200,118},{48,118},{48,68}}, color={0,0,127}),
            Line(points={{200,140},{-30,140},{-30,50}}, color={0,0,127})}),
                                                                     Diagram(
            coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},{200,160}})),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_dxCoilSingle_fan_mix;

    model VAV_SingleZone_drycoil_fan_mix_chilled
      "HVAC system model with a dry cooling coil, ideal chilled water system, electric heating coil, variable speed fan, and mixing box."
      replaceable package MediumAir =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component of type air"
          annotation (choicesAllMatching = true);
      replaceable package MediumWater =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component of type water"
          annotation (choicesAllMatching = true);
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Modelica.SIunits.DimensionlessRatio oaFraction "Minimum airflow rate of system";
      parameter Modelica.SIunits.Temperature supplyAirTempSet "Cooling supply air temperature setpoint";
       parameter Modelica.SIunits.Temperature chwsTempSet "Chilled water supply temperature setpoint";
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
            MediumAir)
                    "Supply air port"
        annotation (Placement(transformation(extent={{190,-20},{210,60}}),
            iconTransformation(extent={{190,-20},{210,60}})));
      Modelica.Fluid.Interfaces.FluidPorts_b returnAir[1](redeclare package
          Medium =
            MediumAir)                                   "Return air"
        annotation (Placement(transformation(extent={{190,-140},{210,-60}}),
            iconTransformation(extent={{190,-140},{210,-60}})));
      Modelica.Blocks.Interfaces.RealInput TheatSetpoint
        "Zone heating setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,140})));
      Modelica.Blocks.Interfaces.RealInput TcoolSetpoint
        "Zone cooling setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,80})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          supplyAirTemp(
                    m_flow_nominal=designAirFlow,
        allowFlowReversal=false,
        tau=0,
        redeclare package Medium = MediumAir) "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{128,38},{148,58}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u heatCoil(
        m_flow_nominal=designAirFlow,
        Q_flow_nominal=designHeatingCapacity,
        u(start=0),
        dp_nominal=0,
        allowFlowReversal=false,
        tau=90,
        redeclare package Medium = MediumAir)
                "Air heating coil"
        annotation (Placement(transformation(extent={{52,38},{72,58}})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation (Placement(
            transformation(extent={{-190,148},{-150,188}}), iconTransformation(
              extent={{-180,160},{-160,180}})));
      Buildings.Fluid.Movers.FlowControlled_m_flow supplyFan(
        m_flow_nominal=designAirFlow,
        nominalValuesDefineDefaultPressureCurve=true,
        dp_nominal=875,
        per(use_powerCharacteristic=false),
        energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
        allowFlowReversal=false,
        use_inputFilter=false,
        redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{-32,38},{-12,58}})));
      Control control(designAirFlow=designAirFlow, minAirFlow=minAirFlow,
        sensitivityGainHeat=sensitivityGainHeat,
        sensitivityGainCool=sensitivityGainCool)
        annotation (Placement(transformation(extent={{-140,0},{-120,20}})));
      Buildings.Fluid.FixedResistances.PressureDrop totalRes(
        m_flow_nominal=designAirFlow,
        dp_nominal=500,
        allowFlowReversal=false,
        redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{-2,38},{18,58}})));
      Modelica.Blocks.Interfaces.RealOutput fanPower
        "Electrical power consumed by the supply fan"
        annotation (Placement(transformation(extent={{200,130},{220,150}}),
            iconTransformation(extent={{200,130},{220,150}})));
      Modelica.Blocks.Interfaces.RealOutput heatPower
        "Electrical power consumed by the heating equipment" annotation (Placement(
            transformation(extent={{200,110},{220,130}}), iconTransformation(extent=
               {{200,110},{220,130}})));
      Modelica.Blocks.Interfaces.RealOutput coolPower
        "Electrical power consumed by the cooling equipment" annotation (Placement(
            transformation(extent={{200,90},{220,110}}), iconTransformation(extent={
                {200,90},{220,110}})));
      Modelica.Blocks.Math.Gain eff(k=1/designHeatingEfficiency)
        annotation (Placement(transformation(extent={{120,90},{140,110}})));
      Buildings.Fluid.Sensors.MassFlowRate returnAirFlow(
                    allowFlowReversal=false, redeclare package Medium = MediumAir)
                    annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=90,
            origin={-66,-6})));
      Buildings.Fluid.Sensors.MassFlowRate exhaustAirFlow(
                    allowFlowReversal=false, redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{-20,-110},{-40,-90}})));
      Buildings.Fluid.Sensors.MassFlowRate oaAirFlow(
                    allowFlowReversal=false, redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{-100,38},{-80,58}})));
      Buildings.Fluid.Sources.Outside out(
                    nPorts=2, redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{-140,36},{-120,56}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort mixedAirTemp(
        m_flow_nominal=designAirFlow,
        allowFlowReversal=false,
        tau=0,
        redeclare package Medium = MediumAir)
                "Mixed air temperature sensor"
        annotation (Placement(transformation(extent={{-60,38},{-40,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort freezeStat(
        m_flow_nominal=designAirFlow,
        allowFlowReversal=false,
        tau=0,
        redeclare package Medium = MediumAir)
                "Temperature sensor to detect freezing conditions"
        annotation (Placement(transformation(extent={{24,38},{44,58}})));
      Modelica.Blocks.Math.Gain fraction(k=oaFraction) annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=0,
            origin={-50,-80})));
      Buildings.Fluid.Movers.BaseClasses.IdealSource idealSourceExhaust(
        control_m_flow=true,
        allowFlowReversal=false,
        m_flow_small=1e-4,
        redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{40,-110},{20,-90}})));
      Buildings.Fluid.Movers.BaseClasses.IdealSource idealSourceRelief(
        control_m_flow=true,
        allowFlowReversal=false,
        m_flow_small=1E-4,
        redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{-80,-110},{-100,-90}})));
      Buildings.Fluid.HeatExchangers.DryEffectivenessNTU dryEffectivenessNTU(
        redeclare package Medium1 = MediumWater,
        redeclare package Medium2 = MediumAir,
        dp1_nominal=0,
        dp2_nominal=0,
        m1_flow_nominal=designCoolingCapacity/4184/4,
        m2_flow_nominal=designAirFlow,
        Q_flow_nominal=designCoolingCapacity,
        configuration=Buildings.Fluid.Types.HeatExchangerConfiguration.CounterFlow,
        allowFlowReversal1=false,
        allowFlowReversal2=false,
        T_a1_nominal=279.15,
        T_a2_nominal=298.15)
        annotation (Placement(transformation(extent={{110,52},{90,32}})));

      Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear val(
        redeclare package Medium = MediumWater,
        dpValve_nominal=6000,
        use_inputFilter=true,
        riseTime=300,
        m_flow_nominal=m_flow_chws)
        annotation (Placement(transformation(
            extent={{-10,10},{10,-10}},
            rotation=-90,
            origin={80,-20})));
      Buildings.Fluid.Sources.Boundary_pT chwSin(nPorts=1, redeclare package
          Medium =
            MediumWater) annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=90,
            origin={80,-80})));
      Buildings.Fluid.Sources.MassFlowSource_T chwSou(
        nPorts=1,
        redeclare package Medium = MediumWater,
        T=chwsTempSet,
        m_flow=m_flow_chws)
                  annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=90,
            origin={120,-80})));
      Buildings.Fluid.Sensors.TemperatureTwoPort chwsTemp(
        allowFlowReversal=false,
        tau=0,
        redeclare package Medium = MediumWater,
        m_flow_nominal=m_flow_chws)
        "Chilled water supply temperature sensor" annotation (Placement(
            transformation(
            extent={{-10,10},{10,-10}},
            rotation=90,
            origin={120,-40})));
      Buildings.Fluid.Sensors.TemperatureTwoPort chwrTemp(
        allowFlowReversal=false,
        tau=0,
        redeclare package Medium = MediumWater,
        m_flow_nominal=m_flow_chws)
        "Chilled water return temperature sensor" annotation (Placement(
            transformation(
            extent={{-10,10},{10,-10}},
            rotation=-90,
            origin={80,-50})));
      Modelica.Blocks.Sources.RealExpression chillerPower(y=chwSou.m_flow*4184*(
            chwrTemp.T - chwsTemp.T)/designCoolingCOP)
        annotation (Placement(transformation(extent={{140,-90},{160,-70}})));
      Buildings.Fluid.Sensors.MassFlowRate chwsFlow(allowFlowReversal=false,
          redeclare package Medium = MediumWater) annotation (Placement(
            transformation(
            extent={{-10,-10},{10,10}},
            rotation=90,
            origin={120,0})));
      Modelica.Blocks.Sources.Constant supplyAirTempSetConst(k=supplyAirTempSet)
        annotation (Placement(transformation(extent={{-40,-10},{-20,10}})));
      Buildings.Controls.Continuous.LimPID conP(
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        yMax=0,
        yMin=-1,
        k=4e-1)
        annotation (Placement(transformation(extent={{-10,10},{10,-10}})));
      Modelica.Blocks.Math.Product product annotation (Placement(transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={32,6})));
      Modelica.Blocks.Math.Gain gain(k=-1)
        annotation (Placement(transformation(extent={{48,0},{60,12}})));
    protected
      final parameter Modelica.SIunits.MassFlowRate m_flow_chws = designCoolingCapacity/4184/4 "Design chilled water supply flow";
    equation

      connect(supplyAirTemp.port_b, supplyAir) annotation (Line(points={{148,48},{200,
              48},{200,20}},      color={0,127,255}));
      connect(control.fanSet, supplyFan.m_flow_in) annotation (Line(points={{-119,4},
              {-98,4},{-98,80},{-22.2,80},{-22.2,60}}, color={0,0,127}));
      connect(TheatSetpoint, control.TheatSet) annotation (Line(points={{-220,
              140},{-160,140},{-160,17},{-141,17}},
                                              color={0,0,127}));
      connect(TcoolSetpoint, control.TcoolSet) annotation (Line(points={{-220,80},
              {-202,80},{-178,80},{-178,12},{-141,12}},
                                                  color={0,0,127}));
      connect(Tmea, control.Tmea) annotation (Line(points={{-220,0},{-181,0},{-181,2.8},
              {-141,2.8}}, color={0,0,127}));
      connect(supplyFan.port_b, totalRes.port_a)
        annotation (Line(points={{-12,48},{-2,48}},  color={0,127,255}));
      connect(supplyFan.P, fanPower) annotation (Line(points={{-11,56},{-6,56},{-6,140},
              {210,140}},        color={0,0,127}));
      connect(eff.y, heatPower) annotation (Line(points={{141,100},{160,100},{160,120},
              {210,120}}, color={0,0,127}));
      connect(oaAirFlow.port_a, out.ports[1]) annotation (Line(points={{-100,48},{-110,
              48},{-120,48}}, color={0,127,255}));
      connect(weaBus, out.weaBus) annotation (Line(
          points={{-170,168},{-170,168},{-170,46},{-140,46},{-140,46.2}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));
      connect(mixedAirTemp.port_b, supplyFan.port_a)
        annotation (Line(points={{-40,48},{-40,48},{-32,48}}, color={0,127,255}));
      connect(oaAirFlow.port_b, mixedAirTemp.port_a)
        annotation (Line(points={{-80,48},{-70,48},{-60,48}}, color={0,127,255}));
      connect(returnAirFlow.port_b, mixedAirTemp.port_a)
        annotation (Line(points={{-66,4},{-66,48},{-60,48}}, color={0,127,255}));
      connect(fraction.u, exhaustAirFlow.m_flow) annotation (Line(points={{-38,-80},
              {-30,-80},{-30,-89}},      color={0,0,127}));
      connect(totalRes.port_b, freezeStat.port_a)
        annotation (Line(points={{18,48},{24,48}}, color={0,127,255}));
      connect(heatCoil.Q_flow, eff.u) annotation (Line(points={{73,54},{80,54},{80,100},
              {86,100},{108,100},{118,100}},          color={0,0,127}));
      connect(control.heaterSet, heatCoil.u) annotation (Line(points={{-119,16},{-100,
              16},{-100,86},{40,86},{46,86},{46,54},{50,54}},
                                                            color={0,0,127}));
      connect(idealSourceExhaust.m_flow_in, supplyFan.m_flow_in) annotation (
          Line(points={{36,-92},{36,-60},{-98,-60},{-98,80},{-22.2,80},{-22.2,
              60}}, color={0,0,127}));
      connect(idealSourceExhaust.port_a, returnAir[1]) annotation (Line(points={{40,-100},
              {200,-100}},                    color={0,127,255}));
      connect(idealSourceExhaust.port_b, exhaustAirFlow.port_a) annotation (
          Line(points={{20,-100},{0,-100},{-20,-100}},
                                                    color={0,127,255}));
      connect(idealSourceRelief.port_a, exhaustAirFlow.port_b)
        annotation (Line(points={{-80,-100},{-70,-100},{-70,-100},{-60,-100},{-60,-100},
              {-40,-100}},                             color={0,127,255}));
      connect(idealSourceRelief.port_b, out.ports[2]) annotation (Line(points={{-100,
              -100},{-106,-100},{-106,44},{-120,44}},     color={0,127,255}));
      connect(fraction.y, idealSourceRelief.m_flow_in) annotation (Line(points={{-61,-80},
              {-84,-80},{-84,-92}},            color={0,0,127}));
      connect(returnAirFlow.port_a, exhaustAirFlow.port_b) annotation (Line(
            points={{-66,-16},{-66,-100},{-40,-100}},
                                                    color={0,127,255}));
      connect(freezeStat.port_b, heatCoil.port_a)
        annotation (Line(points={{44,48},{48,48},{52,48}}, color={0,127,255}));
      connect(chwSou.ports[1], chwsTemp.port_a)
        annotation (Line(points={{120,-70},{120,-50}},
                                                     color={0,0,255}));
      connect(chwSin.ports[1], chwrTemp.port_b)
        annotation (Line(points={{80,-70},{80,-68},{80,-60}},
                                                       color={0,0,255}));
      connect(chwrTemp.port_a, val.port_2)
        annotation (Line(points={{80,-40},{80,-40},{80,-30}},
                                                       color={0,0,127}));
      connect(chillerPower.y, coolPower) annotation (Line(points={{161,-80},{170,-80},
              {170,100},{210,100}}, color={0,0,127}));
      connect(chwsTemp.port_b, chwsFlow.port_a)
        annotation (Line(points={{120,-30},{120,-30},{120,-10}},
                                                              color={0,0,255}));
      connect(heatCoil.port_b,dryEffectivenessNTU. port_a2)
        annotation (Line(points={{72,48},{90,48}}, color={0,127,255}));
      connect(dryEffectivenessNTU.port_b2, supplyAirTemp.port_a) annotation (
          Line(points={{110,48},{120,48},{128,48}}, color={0,127,255}));
      connect(val.port_3, chwsFlow.port_a) annotation (Line(points={{90,-20},{
              120,-20},{120,-10}}, color={0,0,255}));
      connect(chwsFlow.port_b,dryEffectivenessNTU. port_a1) annotation (Line(
            points={{120,10},{120,36},{110,36}}, color={0,0,255}));
      connect(dryEffectivenessNTU.port_b1, val.port_1)
        annotation (Line(points={{90,36},{80,36},{80,-10}}, color={0,0,255}));
      connect(supplyAirTemp.T, conP.u_m) annotation (Line(points={{138,59},{138,
              59},{138,70},{156,70},{156,20},{0,20},{0,12}},
                                                           color={0,0,127}));
      connect(gain.y, val.y) annotation (Line(points={{60.6,6},{64,6},{64,-20},
              {68,-20}}, color={0,0,127}));
      connect(supplyAirTempSetConst.y, conP.u_s)
        annotation (Line(points={{-19,0},{-15.5,0},{-12,0}}, color={0,0,127}));
      connect(conP.y, product.u1) annotation (Line(points={{11,0},{16,0},{16,
              1.77636e-15},{20,1.77636e-15}}, color={0,0,127}));
      connect(gain.u, product.y)
        annotation (Line(points={{46.8,6},{46.8,6},{43,6}}, color={0,0,127}));
      connect(product.u2, control.coolSignal) annotation (Line(points={{20,12},
              {-88,12},{-119,12}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},
                {200,160}}), graphics={
            Rectangle(
              extent={{-200,160},{-160,-160}},
              lineColor={0,0,0},
              fillColor={170,255,255},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-160,160},{200,-160}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{180,40},{-160,0}},
              lineColor={175,175,175},
              fillColor={175,175,175},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-32,36},{-4,22}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{180,-72},{-160,-112}},
              lineColor={175,175,175},
              fillColor={175,175,175},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-80,0},{-120,-72}},
              lineColor={175,175,175},
              fillColor={175,175,175},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-48,36},{-14,2}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-38,26},{-24,12}},
              lineColor={0,0,0},
              fillColor={0,0,0},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{40,40},{54,0}},
              lineColor={255,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Backward),
            Rectangle(
              extent={{102,40},{116,0}},
              lineColor={0,0,255},
              fillColor={255,255,255},
              fillPattern=FillPattern.Backward),
            Rectangle(
              extent={{42,54},{52,46}},
              lineColor={0,0,0},
              fillColor={0,0,0},
              fillPattern=FillPattern.Backward),
            Rectangle(
              extent={{38,56},{56,54}},
              lineColor={0,0,0},
              fillColor={0,0,0},
              fillPattern=FillPattern.Backward),
            Line(points={{44,56},{44,60}}, color={0,0,0}),
            Line(points={{50,56},{50,60}}, color={0,0,0}),
            Line(points={{48,40},{48,48}}, color={0,0,0}),
            Rectangle(
              extent={{-140,40},{-126,0}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Backward),
            Rectangle(
              extent={{-140,-72},{-126,-112}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Backward),
            Rectangle(
              extent={{-7,20},{7,-20}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Backward,
              origin={-100,-37},
              rotation=90),
            Line(points={{-160,160},{-160,-160}}, color={0,0,0}),
            Line(points={{200,100},{108,100},{108,70}}, color={0,0,127}),
            Line(points={{200,118},{48,118},{48,68}}, color={0,0,127}),
            Line(points={{200,140},{-30,140},{-30,50}}, color={0,0,127}),
            Line(points={{104,0},{104,-46}}, color={0,0,255}),
            Line(points={{114,0},{114,-46}}, color={0,0,255}),
            Line(points={{104,-26},{114,-26}}, color={0,0,255}),
            Polygon(
              points={{-3,4},{-3,-4},{3,0},{-3,4}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid,
              origin={115,-24},
              rotation=-90),
            Polygon(
              points={{110,-22},{110,-30},{116,-26},{110,-22}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),
            Polygon(
              points={{-4,-3},{4,-3},{0,3},{-4,-3}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid,
              origin={115,-28},
              rotation=0),
            Line(points={{116,-26},{122,-26}}, color={0,0,0}),
            Line(points={{122,-24},{122,-30}}, color={0,0,0}),
            Line(
              points={{104,-46},{104,-60}},
              color={0,0,255},
              pattern=LinePattern.Dot),
            Line(
              points={{114,-46},{114,-60}},
              color={0,0,255},
              pattern=LinePattern.Dot)}),                            Diagram(
            coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},{200,160}})),
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          Tolerance=1e-05,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_drycoil_fan_mix_chilled;

    model VAV_SingleZone_drycoil_fan_mix_chiller
      "HVAC system model with a dry cooling coil, air-cooled chiller, electric heating coil, variable speed fan, and mixing box."
      replaceable package MediumAir =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component of type air"
          annotation (choicesAllMatching = true);
      replaceable package MediumWater =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component of type water"
          annotation (choicesAllMatching = true);
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Modelica.SIunits.DimensionlessRatio oaFraction "Minimum airflow rate of system";
      parameter Modelica.SIunits.Temperature supplyAirTempSet "Cooling supply air temperature setpoint";
      parameter Modelica.SIunits.Temperature chwsTempSet "Chilled water supply temperature setpoint";
      parameter Modelica.SIunits.Power designHeatingCapacity "Design heating capacity of heating coil";
      parameter Real designHeatingEfficiency "Design heating efficiency of the heating coil";
      parameter Modelica.SIunits.Power designCoolingCapacity "Design heating capacity of cooling coil";
      parameter Real sensitivityGainHeat = 2 "[K] Gain sensitivity on heating controller";
      parameter Real sensitivityGainCool = 2 "[K] Gain sensitivity on cooling controller";
      Modelica.Blocks.Interfaces.RealInput Tmea
        "Measured mean zone air temperature" annotation (Placement(
            transformation(
            extent={{-20,-20},{20,20}},
            rotation=0,
            origin={-220,0})));
      Modelica.Fluid.Interfaces.FluidPorts_b supplyAir(redeclare package Medium =
            MediumAir)
                    "Supply air port"
        annotation (Placement(transformation(extent={{190,-20},{210,60}}),
            iconTransformation(extent={{190,-20},{210,60}})));
      Modelica.Fluid.Interfaces.FluidPorts_b returnAir[1](redeclare package Medium =
            MediumAir)                                   "Return air"
        annotation (Placement(transformation(extent={{190,-140},{210,-60}}),
            iconTransformation(extent={{190,-140},{210,-60}})));
      Modelica.Blocks.Interfaces.RealInput TheatSetpoint
        "Zone heating setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,140})));
      Modelica.Blocks.Interfaces.RealInput TcoolSetpoint
        "Zone cooling setpoint temperature"  annotation (Placement(
            transformation(
            extent={{20,-20},{-20,20}},
            rotation=180,
            origin={-220,80})));
      Buildings.Fluid.Sensors.TemperatureTwoPort
                                          supplyAirTemp(
                    m_flow_nominal=designAirFlow,
        allowFlowReversal=false,
        tau=0,
        redeclare package Medium = MediumAir) "Supply air temperature sensor"
        annotation (Placement(transformation(extent={{128,38},{148,58}})));
      Buildings.Fluid.HeatExchangers.HeaterCooler_u heatCoil(
        m_flow_nominal=designAirFlow,
        Q_flow_nominal=designHeatingCapacity,
        u(start=0),
        dp_nominal=0,
        allowFlowReversal=false,
        tau=90,
        redeclare package Medium = MediumAir)
                "Air heating coil"
        annotation (Placement(transformation(extent={{52,38},{72,58}})));
      Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation (Placement(
            transformation(extent={{-190,148},{-150,188}}), iconTransformation(
              extent={{-180,160},{-160,180}})));
      Buildings.Fluid.Movers.FlowControlled_m_flow supplyFan(
        m_flow_nominal=designAirFlow,
        nominalValuesDefineDefaultPressureCurve=true,
        dp_nominal=875,
        per(use_powerCharacteristic=false),
        energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
        allowFlowReversal=false,
        use_inputFilter=false,
        redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{-32,38},{-12,58}})));
      Control control(designAirFlow=designAirFlow, minAirFlow=minAirFlow,
        sensitivityGainHeat=sensitivityGainHeat,
        sensitivityGainCool=sensitivityGainCool)
        annotation (Placement(transformation(extent={{-140,0},{-120,20}})));
      Buildings.Fluid.FixedResistances.PressureDrop totalRes(
        m_flow_nominal=designAirFlow,
        dp_nominal=500,
        allowFlowReversal=false,
        redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{-2,38},{18,58}})));
      Modelica.Blocks.Interfaces.RealOutput fanPower
        "Electrical power consumed by the supply fan"
        annotation (Placement(transformation(extent={{200,130},{220,150}}),
            iconTransformation(extent={{200,130},{220,150}})));
      Modelica.Blocks.Interfaces.RealOutput heatPower
        "Electrical power consumed by the heating equipment" annotation (Placement(
            transformation(extent={{200,110},{220,130}}), iconTransformation(extent=
               {{200,110},{220,130}})));
      Modelica.Blocks.Interfaces.RealOutput coolPower
        "Electrical power consumed by the cooling equipment" annotation (Placement(
            transformation(extent={{200,90},{220,110}}), iconTransformation(extent={
                {200,90},{220,110}})));
      Modelica.Blocks.Math.Gain eff(k=1/designHeatingEfficiency)
        annotation (Placement(transformation(extent={{120,90},{140,110}})));
      Buildings.Fluid.Sensors.MassFlowRate returnAirFlow(
                    allowFlowReversal=false, redeclare package Medium = MediumAir)
                    annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=90,
            origin={-66,-6})));
      Buildings.Fluid.Sensors.MassFlowRate exhaustAirFlow(
                    allowFlowReversal=false, redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{-20,-110},{-40,-90}})));
      Buildings.Fluid.Sensors.MassFlowRate oaAirFlow(
                    allowFlowReversal=false, redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{-100,38},{-80,58}})));
      Buildings.Fluid.Sources.Outside out(
                    nPorts=3, redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{-140,36},{-120,56}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort mixedAirTemp(
        m_flow_nominal=designAirFlow,
        allowFlowReversal=false,
        tau=0,
        redeclare package Medium = MediumAir)
                "Mixed air temperature sensor"
        annotation (Placement(transformation(extent={{-60,38},{-40,58}})));
      Buildings.Fluid.Sensors.TemperatureTwoPort freezeStat(
        m_flow_nominal=designAirFlow,
        allowFlowReversal=false,
        tau=0,
        redeclare package Medium = MediumAir)
                "Temperature sensor to detect freezing conditions"
        annotation (Placement(transformation(extent={{24,38},{44,58}})));
      Modelica.Blocks.Math.Gain fraction(k=oaFraction) annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=0,
            origin={-50,-80})));
      Buildings.Fluid.Movers.BaseClasses.IdealSource idealSourceExhaust(
        control_m_flow=true,
        allowFlowReversal=false,
        m_flow_small=1e-4,
        redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{40,-110},{20,-90}})));
      Buildings.Fluid.Movers.BaseClasses.IdealSource idealSourceRelief(
        control_m_flow=true,
        allowFlowReversal=false,
        m_flow_small=1E-4,
        redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{-80,-110},{-100,-90}})));
      Buildings.Fluid.HeatExchangers.DryEffectivenessNTU dryEffectivenessNTU(
        redeclare package Medium1 = MediumWater,
        redeclare package Medium2 = MediumAir,
        dp1_nominal=0,
        dp2_nominal=0,
        m2_flow_nominal=designAirFlow,
        Q_flow_nominal=designCoolingCapacity,
        configuration=Buildings.Fluid.Types.HeatExchangerConfiguration.CounterFlow,
        allowFlowReversal1=false,
        allowFlowReversal2=false,
        m1_flow_nominal=m_flow_chws,
        T_a1_nominal=279.15,
        T_a2_nominal=298.15)
        annotation (Placement(transformation(extent={{110,52},{90,32}})));

      Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear val(
        redeclare package Medium = MediumWater,
        m_flow_nominal=m_flow_chws,
        dpValve_nominal=12000,
        dpFixed_nominal={0,0},
        use_inputFilter=true,
        tau=10,
        riseTime=300)
        annotation (Placement(transformation(
            extent={{-10,10},{10,-10}},
            rotation=-90,
            origin={80,-20})));
      Buildings.Fluid.Sources.MassFlowSource_T cwSou(
        redeclare package Medium = MediumAir,
        nPorts=1,
        use_T_in=true,
        m_flow=m_flow_cas)
                       annotation (Placement(transformation(
            extent={{10,-10},{-10,10}},
            rotation=0,
            origin={138,-148})));
      Buildings.Fluid.Sensors.TemperatureTwoPort chwsTemp(
        allowFlowReversal=false,
        tau=0,
        redeclare package Medium = MediumWater,
        m_flow_nominal=m_flow_chws)
        "Chilled water supply temperature sensor" annotation (Placement(
            transformation(
            extent={{-10,10},{10,-10}},
            rotation=90,
            origin={120,-40})));
      Buildings.Fluid.Sensors.TemperatureTwoPort chwrTemp(
        allowFlowReversal=false,
        tau=0,
        redeclare package Medium = MediumWater,
        m_flow_nominal=m_flow_chws)
        "Chilled water return temperature sensor" annotation (Placement(
            transformation(
            extent={{-10,10},{10,-10}},
            rotation=-90,
            origin={80,-50})));
      Buildings.Fluid.Sensors.MassFlowRate chwsFlow(allowFlowReversal=false,
          redeclare package Medium = MediumWater) annotation (Placement(
            transformation(
            extent={{-10,-10},{10,10}},
            rotation=90,
            origin={120,0})));
      Modelica.Blocks.Sources.Constant supplyAirTempSetConst(k=supplyAirTempSet)
        annotation (Placement(transformation(extent={{-40,-10},{-20,10}})));
      Buildings.Controls.Continuous.LimPID conP(
        controllerType=Modelica.Blocks.Types.SimpleController.P,
        yMax=0,
        yMin=-1,
        k=4e-1)
        annotation (Placement(transformation(extent={{-10,10},{10,-10}})));
      Modelica.Blocks.Math.Product product annotation (Placement(transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={32,6})));
      Modelica.Blocks.Math.Gain gain(k=-1)
        annotation (Placement(transformation(extent={{48,0},{60,12}})));
      Buildings.Fluid.Movers.FlowControlled_m_flow chwPump(
        use_inputFilter=false,
        allowFlowReversal=false,
        redeclare package Medium = MediumWater,
        energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
        m_flow_nominal=m_flow_chws,
        addPowerToMedium=false,
        per(
          hydraulicEfficiency(eta={1}),
          motorEfficiency(eta={0.9}),
          motorCooledByFluid=false),
        dp_nominal=12000)                                         annotation (
          Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=90,
            origin={120,-86})));
      Buildings.Fluid.Chillers.ElectricEIR chillerAirCooled(
        allowFlowReversal1=false,
        allowFlowReversal2=false,
        redeclare package Medium1 = MediumAir,
        redeclare package Medium2 = MediumWater,
        m2_flow_nominal=m_flow_chws,
        dp1_nominal=0,
        m1_flow_nominal=m_flow_cas,
        dp2_nominal=0,
        per(
          capFunT={1.0433811,0.0407077,0.0004506,-0.0041514,-8.86e-5,-0.0003467},
          PLRMax=1.2,
          EIRFunT={0.5961915,-0.0099496,0.0007888,0.0004506,0.0004875,-0.0007623},
          EIRFunPLR={1.6853121,-0.9993443,0.3140322},
          COP_nominal=COP_nominal,
          QEva_flow_nominal=-designCoolingCapacity,
          mEva_flow_nominal=m_flow_chws,
          mCon_flow_nominal=m_flow_cas,
          TEvaLvg_nominal=chwsTempSet,
          PLRMinUnl=0.1,
          PLRMin=0.1,
          etaMotor=1,
          TEvaLvgMin=274.15,
          TEvaLvgMax=293.15,
          TConEnt_nominal=302.55,
          TConEntMin=274.15,
          TConEntMax=323.15))
        annotation (Placement(transformation(extent={{110,-132},{90,-152}})));
      Modelica.Blocks.Sources.Constant chwsTempSetConst(k=chwsTempSet)
        annotation (Placement(transformation(extent={{160,-126},{140,-106}})));
      Modelica.Blocks.Sources.Constant chwsMassFlowConst(k=m_flow_chws)
        annotation (Placement(transformation(extent={{160,-80},{140,-60}})));
      Modelica.Blocks.Interfaces.RealOutput pumpPower "Electrical power consumed"
        annotation (Placement(transformation(extent={{200,70},{220,90}})));
      Modelica.Blocks.Sources.BooleanConstant on
        annotation (Placement(transformation(extent={{198,-150},{178,-130}})));
    protected
      final parameter Modelica.SIunits.DimensionlessRatio COP_nominal = 5.5 "Nominal COP of the chiller";
      final parameter Modelica.SIunits.MassFlowRate m_flow_chws = designCoolingCapacity/4184/4 "Design chilled water supply flow";
      final parameter Modelica.SIunits.MassFlowRate m_flow_cas = designCoolingCapacity*(1+1/COP_nominal)/1008/10 "Design condenser air flow";
    public
      Buildings.Fluid.Sources.FixedBoundary fixedBou(redeclare package Medium =
            MediumWater, nPorts=1)
        annotation (Placement(transformation(extent={{40,-140},{60,-120}})));
    equation

      connect(supplyAirTemp.port_b, supplyAir) annotation (Line(points={{148,48},{200,
              48},{200,20}},      color={0,127,255}));
      connect(control.fanSet, supplyFan.m_flow_in) annotation (Line(points={{-119,4},
              {-98,4},{-98,80},{-22.2,80},{-22.2,60}}, color={0,0,127}));
      connect(TheatSetpoint, control.TheatSet) annotation (Line(points={{-220,
              140},{-160,140},{-160,17},{-141,17}},
                                              color={0,0,127}));
      connect(TcoolSetpoint, control.TcoolSet) annotation (Line(points={{-220,80},
              {-202,80},{-178,80},{-178,12},{-141,12}},
                                                  color={0,0,127}));
      connect(Tmea, control.Tmea) annotation (Line(points={{-220,0},{-181,0},{-181,2.8},
              {-141,2.8}}, color={0,0,127}));
      connect(supplyFan.port_b, totalRes.port_a)
        annotation (Line(points={{-12,48},{-2,48}},  color={0,127,255}));
      connect(supplyFan.P, fanPower) annotation (Line(points={{-11,56},{-6,56},{-6,140},
              {210,140}},        color={0,0,127}));
      connect(eff.y, heatPower) annotation (Line(points={{141,100},{160,100},{160,120},
              {210,120}}, color={0,0,127}));
      connect(oaAirFlow.port_a, out.ports[1]) annotation (Line(points={{-100,48},
              {-120,48},{-120,48.6667}},
                              color={0,127,255}));
      connect(weaBus, out.weaBus) annotation (Line(
          points={{-170,168},{-170,168},{-170,46},{-140,46},{-140,46.2}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));
      connect(mixedAirTemp.port_b, supplyFan.port_a)
        annotation (Line(points={{-40,48},{-40,48},{-32,48}}, color={0,127,255}));
      connect(oaAirFlow.port_b, mixedAirTemp.port_a)
        annotation (Line(points={{-80,48},{-70,48},{-60,48}}, color={0,127,255}));
      connect(returnAirFlow.port_b, mixedAirTemp.port_a)
        annotation (Line(points={{-66,4},{-66,48},{-60,48}}, color={0,127,255}));
      connect(fraction.u, exhaustAirFlow.m_flow) annotation (Line(points={{-38,-80},
              {-30,-80},{-30,-89}},      color={0,0,127}));
      connect(totalRes.port_b, freezeStat.port_a)
        annotation (Line(points={{18,48},{24,48}}, color={0,127,255}));
      connect(heatCoil.Q_flow, eff.u) annotation (Line(points={{73,54},{80,54},{80,100},
              {86,100},{108,100},{118,100}},          color={0,0,127}));
      connect(control.heaterSet, heatCoil.u) annotation (Line(points={{-119,16},
              {-100,16},{-100,82},{40,82},{46,82},{46,54},{50,54}},
                                                            color={0,0,127}));
      connect(idealSourceExhaust.m_flow_in, supplyFan.m_flow_in) annotation (
          Line(points={{36,-92},{36,-60},{-98,-60},{-98,80},{-22.2,80},{-22.2,
              60}}, color={0,0,127}));
      connect(idealSourceExhaust.port_a, returnAir[1]) annotation (Line(points={{40,-100},
              {200,-100}},                    color={0,127,255}));
      connect(idealSourceExhaust.port_b, exhaustAirFlow.port_a) annotation (
          Line(points={{20,-100},{0,-100},{-20,-100}},
                                                    color={0,127,255}));
      connect(idealSourceRelief.port_a, exhaustAirFlow.port_b)
        annotation (Line(points={{-80,-100},{-70,-100},{-60,-100},{-40,-100}},
                                                       color={0,127,255}));
      connect(idealSourceRelief.port_b, out.ports[2]) annotation (Line(points={{-100,
              -100},{-106,-100},{-106,46},{-120,46}},     color={0,127,255}));
      connect(fraction.y, idealSourceRelief.m_flow_in) annotation (Line(points={{-61,-80},
              {-84,-80},{-84,-92}},            color={0,0,127}));
      connect(returnAirFlow.port_a, exhaustAirFlow.port_b) annotation (Line(
            points={{-66,-16},{-66,-100},{-40,-100}},
                                                    color={0,127,255}));
      connect(freezeStat.port_b, heatCoil.port_a)
        annotation (Line(points={{44,48},{48,48},{52,48}}, color={0,127,255}));
      connect(chwrTemp.port_a, val.port_2)
        annotation (Line(points={{80,-40},{80,-40},{80,-30}},
                                                       color={0,0,255},
          thickness=0.5));
      connect(chwsTemp.port_b, chwsFlow.port_a)
        annotation (Line(points={{120,-30},{120,-30},{120,-10}},
                                                              color={0,0,255},
          thickness=0.5));
      connect(heatCoil.port_b,dryEffectivenessNTU. port_a2)
        annotation (Line(points={{72,48},{90,48}}, color={0,127,255}));
      connect(dryEffectivenessNTU.port_b2, supplyAirTemp.port_a) annotation (
          Line(points={{110,48},{120,48},{128,48}}, color={0,127,255}));
      connect(val.port_3, chwsFlow.port_a) annotation (Line(points={{90,-20},{
              120,-20},{120,-10}}, color={0,0,255},
          thickness=0.5));
      connect(chwsFlow.port_b,dryEffectivenessNTU. port_a1) annotation (Line(
            points={{120,10},{120,36},{110,36}}, color={0,0,255},
          thickness=0.5));
      connect(dryEffectivenessNTU.port_b1, val.port_1)
        annotation (Line(points={{90,36},{80,36},{80,-10}}, color={0,0,255},
          thickness=0.5));
      connect(supplyAirTemp.T, conP.u_m) annotation (Line(points={{138,59},{138,
              59},{138,70},{156,70},{156,20},{0,20},{0,12}},
                                                           color={0,0,127}));
      connect(gain.y, val.y) annotation (Line(points={{60.6,6},{64,6},{64,-20},
              {68,-20}}, color={0,0,127}));
      connect(supplyAirTempSetConst.y, conP.u_s)
        annotation (Line(points={{-19,0},{-15.5,0},{-12,0}}, color={0,0,127}));
      connect(conP.y, product.u1) annotation (Line(points={{11,0},{16,0},{16,
              1.77636e-15},{20,1.77636e-15}}, color={0,0,127}));
      connect(gain.u, product.y)
        annotation (Line(points={{46.8,6},{46.8,6},{43,6}}, color={0,0,127}));
      connect(product.u2, control.coolSignal) annotation (Line(points={{20,12},
              {-88,12},{-119,12}}, color={0,0,127}));
      connect(chillerAirCooled.port_a2, chwrTemp.port_b)
        annotation (Line(points={{90,-136},{80,-136},{80,-60}}, color={0,0,255},
          thickness=0.5));
      connect(chillerAirCooled.port_b2, chwPump.port_a) annotation (Line(points={{110,
              -136},{120,-136},{120,-96}},  color={0,0,255},
          thickness=0.5));
      connect(chwPump.port_b, chwsTemp.port_a)
        annotation (Line(points={{120,-76},{120,-76},{120,-50}}, color={0,0,255},
          thickness=0.5));
      connect(cwSou.ports[1], chillerAirCooled.port_a1) annotation (Line(points={{128,
              -148},{128,-148},{110,-148}}, color={0,127,255}));
      connect(chillerAirCooled.port_b1, out.ports[3]) annotation (Line(points={{90,-148},
              {-14,-148},{-112,-148},{-112,43.3333},{-120,43.3333}}, color={0,127,255}));
      connect(weaBus.TDryBul, cwSou.T_in) annotation (Line(
          points={{-170,168},{-170,168},{-170,-158},{160,-158},{160,-144},{150,-144}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}}));

      connect(chwsTempSetConst.y, chillerAirCooled.TSet) annotation (Line(points={{139,
              -116},{124,-116},{124,-139},{112,-139}}, color={0,0,127}));
      connect(chwsMassFlowConst.y, chwPump.m_flow_in) annotation (Line(points={{139,-70},
              {100,-70},{100,-86.2},{108,-86.2}},      color={0,0,127}));
      connect(chwPump.P, pumpPower) annotation (Line(points={{112,-75},{112,-52},{180,
              -52},{180,80},{210,80}}, color={0,0,127}));
      connect(on.y, chillerAirCooled.on) annotation (Line(points={{177,-140},{124,-140},
              {124,-145},{112,-145}}, color={255,0,255}));
      connect(chillerAirCooled.P, coolPower) annotation (Line(points={{89,-151},{84,
              -151},{84,-128},{98,-128},{98,-50},{178,-50},{178,100},{210,100}},
            color={0,0,127}));
      connect(pumpPower, pumpPower)
        annotation (Line(points={{210,80},{210,80},{210,80}}, color={0,0,127}));
      connect(fixedBou.ports[1], chwrTemp.port_b) annotation (Line(
          points={{60,-130},{70,-130},{70,-136},{80,-136},{80,-60}},
          color={0,0,255},
          thickness=0.5));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},
                {200,160}}), graphics={
            Rectangle(
              extent={{-200,160},{-160,-160}},
              lineColor={0,0,0},
              fillColor={170,255,255},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-160,160},{200,-160}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{180,40},{-160,0}},
              lineColor={175,175,175},
              fillColor={175,175,175},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-32,36},{-4,22}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{180,-72},{-160,-112}},
              lineColor={175,175,175},
              fillColor={175,175,175},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-80,0},{-120,-72}},
              lineColor={175,175,175},
              fillColor={175,175,175},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-48,36},{-14,2}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{-38,26},{-24,12}},
              lineColor={0,0,0},
              fillColor={0,0,0},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{40,40},{54,0}},
              lineColor={255,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Backward),
            Rectangle(
              extent={{102,40},{116,0}},
              lineColor={0,0,255},
              fillColor={255,255,255},
              fillPattern=FillPattern.Backward),
            Rectangle(
              extent={{42,54},{52,46}},
              lineColor={0,0,0},
              fillColor={0,0,0},
              fillPattern=FillPattern.Backward),
            Rectangle(
              extent={{38,56},{56,54}},
              lineColor={0,0,0},
              fillColor={0,0,0},
              fillPattern=FillPattern.Backward),
            Line(points={{44,56},{44,60}}, color={0,0,0}),
            Line(points={{50,56},{50,60}}, color={0,0,0}),
            Line(points={{48,40},{48,48}}, color={0,0,0}),
            Rectangle(
              extent={{-140,40},{-126,0}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Backward),
            Rectangle(
              extent={{-140,-72},{-126,-112}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Backward),
            Rectangle(
              extent={{-7,20},{7,-20}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Backward,
              origin={-100,-37},
              rotation=90),
            Line(points={{-160,160},{-160,-160}}, color={0,0,0}),
            Line(points={{200,100},{86,100},{86,46}},   color={0,0,127}),
            Line(points={{200,118},{48,118},{48,68}}, color={0,0,127}),
            Line(points={{200,140},{-30,140},{-30,50}}, color={0,0,127}),
            Line(points={{104,0},{104,-66}}, color={0,0,255}),
            Line(points={{114,0},{114,-66}}, color={0,0,255}),
            Line(points={{104,-26},{114,-26}}, color={0,0,255}),
            Polygon(
              points={{-3,4},{-3,-4},{3,0},{-3,4}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid,
              origin={115,-24},
              rotation=-90),
            Polygon(
              points={{110,-22},{110,-30},{116,-26},{110,-22}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),
            Polygon(
              points={{-4,-3},{4,-3},{0,3},{-4,-3}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid,
              origin={115,-28},
              rotation=0),
            Line(points={{116,-26},{122,-26}}, color={0,0,0}),
            Line(points={{122,-24},{122,-30}}, color={0,0,0}),
            Ellipse(
              extent={{96,-124},{124,-152}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),
            Polygon(
              points={{110,-124},{98,-144},{122,-144},{110,-124}},
              lineColor={0,0,0},
              fillColor={0,0,0},
              fillPattern=FillPattern.Solid),
            Line(points={{114,-116},{114,-124}},
                                             color={0,0,255}),
            Line(points={{104,-116},{104,-124}},
                                             color={0,0,255}),
            Ellipse(
              extent={{84,-148},{110,-158}},
              lineColor={0,0,0},
              fillColor={95,95,95},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{110,-148},{136,-158}},
              lineColor={0,0,0},
              fillColor={95,95,95},
              fillPattern=FillPattern.Solid),
            Ellipse(
              extent={{108,-48},{120,-58}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),
            Polygon(
              points={{114,-48},{110,-56},{118,-56},{114,-48}},
              lineColor={0,0,0},
              fillColor={0,0,0},
              fillPattern=FillPattern.Solid),
            Line(points={{200,80},{132,80},{132,46}},   color={0,0,127}),
            Line(points={{124,-54},{132,-54},{132,-4}}, color={0,0,127}),
            Line(points={{92,-136},{86,-136},{86,-4}},  color={0,0,127})}),
                                                                     Diagram(
            coordinateSystem(preserveAspectRatio=false, extent={{-200,-160},{200,160}})),
        experiment(
          StopTime=518400,
          Interval=3600,
          Tolerance=1e-06,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_drycoil_fan_mix_chiller;

    block FMI_SingleZoneVAVWithChiller
      extends Buildings.Fluid.FMI.ExportContainers.HVACZone(hvacAda(nPorts=2));
      replaceable package MediumWater =
          Modelica.Media.Interfaces.PartialMedium "Medium in the component of type water"
          annotation (choicesAllMatching = true);
      parameter String filNam = "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos" "File name of weather file.";
      parameter Modelica.SIunits.MassFlowRate designAirFlow "Design airflow rate of system";
      parameter Modelica.SIunits.MassFlowRate minAirFlow "Minimum airflow rate of system";
      parameter Modelica.SIunits.DimensionlessRatio oaFraction "Minimum airflow rate of system";
      parameter Modelica.SIunits.Temperature supplyAirTempSet "Cooling supply air temperature setpoint";
      parameter Modelica.SIunits.Temperature chwsTempSet "Chilled water supply temperature setpoint";
      parameter Modelica.SIunits.Power designHeatingCapacity "Design heating capacity of heating coil";
      parameter Real designHeatingEfficiency "Design heating efficiency of the heating coil";
      parameter Modelica.SIunits.Power designCoolingCapacity "Design heating capacity of cooling coil";
      parameter Real sensitivityGainHeat = 2 "[K] Gain sensitivity on heating controller";
      parameter Real sensitivityGainCool = 2 "[K] Gain sensitivity on cooling controller";
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=filNam)
        annotation (Placement(transformation(extent={{-140,120},{-120,140}})));
      VAV_SingleZone_drycoil_fan_mix_chiller vAV_SingleZone_drycoil_fan_mix_chiller(
        designAirFlow=designAirFlow,
        minAirFlow=minAirFlow,
        oaFraction=oaFraction,
        supplyAirTempSet=supplyAirTempSet,
        chwsTempSet=chwsTempSet,
        designHeatingCapacity=designHeatingCapacity,
        designHeatingEfficiency=designHeatingEfficiency,
        designCoolingCapacity=designCoolingCapacity,
        sensitivityGainHeat=sensitivityGainHeat,
        sensitivityGainCool=sensitivityGainCool,
        redeclare package MediumAir = Medium,
        redeclare package MediumWater = MediumWater)
        annotation (Placement(transformation(extent={{-20,-16},{20,16}})));
      Schedules.TSetCoo tSetCoo
        annotation (Placement(transformation(extent={{-120,-30},{-100,-10}})));
      Schedules.TSetHea tSetHea
        annotation (Placement(transformation(extent={{-120,10},{-100,30}})));
      Modelica.Blocks.Continuous.Integrator totalFanEnergy
        annotation (Placement(transformation(extent={{60,-80},{80,-60}})));
      Modelica.Blocks.Continuous.Integrator totalHeatingEnergy
        annotation (Placement(transformation(extent={{60,-100},{80,-80}})));
      Modelica.Blocks.Continuous.Integrator totalCoolingEnergy
        annotation (Placement(transformation(extent={{60,-120},{80,-100}})));
      Modelica.Blocks.Continuous.Integrator totalPumpEnergy
        annotation (Placement(transformation(extent={{60,-140},{80,-120}})));
    equation
      connect(vAV_SingleZone_drycoil_fan_mix_chiller.supplyAir, hvacAda.ports[1])
        annotation (Line(points={{20,2},{78,2},{78,140},{120,140}}, color={0,127,255}));
      connect(vAV_SingleZone_drycoil_fan_mix_chiller.returnAir[1], hvacAda.ports[2])
        annotation (Line(points={{20,-10},{56,-10},{90,-10},{90,140},{120,140}},
            color={0,127,255}));
      connect(hvacAda.TAirZon[1], vAV_SingleZone_drycoil_fan_mix_chiller.Tmea)
        annotation (Line(points={{124,128},{124,128},{124,-24},{-32,-24},{-32,0},{-22,
              0}}, color={0,0,127}));
      connect(weaDat.weaBus, vAV_SingleZone_drycoil_fan_mix_chiller.weaBus)
        annotation (Line(
          points={{-120,130},{-17,130},{-17,17}},
          color={255,204,51},
          thickness=0.5));
      connect(tSetHea.y[1], vAV_SingleZone_drycoil_fan_mix_chiller.TheatSetpoint)
        annotation (Line(points={{-99,20},{-60,20},{-60,14},{-22,14}}, color={0,
              0,127}));
      connect(tSetCoo.y[1], vAV_SingleZone_drycoil_fan_mix_chiller.TcoolSetpoint)
        annotation (Line(points={{-99,-20},{-78,-20},{-60,-20},{-60,8},{-22,8}},
                     color={0,0,127}));
      connect(vAV_SingleZone_drycoil_fan_mix_chiller.fanPower, totalFanEnergy.u)
        annotation (Line(points={{21,14},{40,14},{40,-70},{58,-70}}, color={0,0,
              127}));
      connect(vAV_SingleZone_drycoil_fan_mix_chiller.heatPower,
        totalHeatingEnergy.u) annotation (Line(points={{21,12},{36,12},{36,-90},
              {58,-90}}, color={0,0,127}));
      connect(vAV_SingleZone_drycoil_fan_mix_chiller.coolPower,
        totalCoolingEnergy.u) annotation (Line(points={{21,10},{32,10},{32,-110},
              {58,-110}}, color={0,0,127}));
      connect(vAV_SingleZone_drycoil_fan_mix_chiller.pumpPower, totalPumpEnergy.u)
        annotation (Line(points={{21,8},{28,8},{28,-130},{58,-130}}, color={0,0,
              127}));
    end FMI_SingleZoneVAVWithChiller;
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
    extends Modelica.Icons.ExamplesPackage;
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
        designAirFlow=0.25,
        designHeatingCapacity=1000,
        minAirFlow=0.2*0.25,
        sensitivityGainCool=1,
        supplyAirTempSet=286.15,
        designCoolingCapacity=3000)
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
      connect(vAV_SingleZone.supplyAir, senMasFlo.port_a) annotation (Line(
            points={{-2,11.2},{4,11.2},{4,12},{12,12},{12,30},{30,30}}, color={
              0,127,255}));
      connect(senMasFlo.port_a, senTem.port)
        annotation (Line(points={{30,30},{20,30},{20,60}}, color={0,127,255}));
      connect(TheatSet.y, vAV_SingleZone.TheatSetpoint) annotation (Line(points=
             {{-79,58},{-62,58},{-62,19},{-44,19}}, color={0,0,127}));
      connect(TcoolSet.y, vAV_SingleZone.TcoolSetpoint) annotation (Line(points=
             {{-81,10},{-62,10},{-62,13.8},{-44,13.8}}, color={0,0,127}));
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
        sensitivityGainCool=0.25,
        supplyAirTempSet=286.15,
        dxCoilPerformance(sta={
              Buildings.Fluid.HeatExchangers.DXCoils.AirCooled.Data.Generic.BaseClasses.Stage(
                  spe=1,
                  nomVal=
                Buildings.Fluid.HeatExchangers.DXCoils.AirCooled.Data.Generic.BaseClasses.NominalValues(
                    Q_flow_nominal=-7000,
                    COP_nominal=3,
                    SHR_nominal=0.8,
                    m_flow_nominal=0.75),
                  perCur=dxCoilPerformanceCurve)}))
        annotation (Placement(transformation(extent={{-40,-10},{0,22}})));
      ThermalEnvelope.Case600_AirHVAC   singleZoneAirHVAC(
          designAirFlow=0.75, lat=weaDat.lat)
        annotation (Placement(transformation(extent={{32,-4},{52,16}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=
            "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos")
        annotation (Placement(transformation(extent={{-100,80},{-80,100}})));
      Buildings.Fluid.HeatExchangers.DXCoils.AirCooled.Examples.PerformanceCurves.Curve_II
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
        sensitivityGainCool=2,
        oaFraction=0.2,
        supplyAirTempSet=286.15)
        annotation (Placement(transformation(extent={{-40,-10},{0,22}})));
      ThermalEnvelope.Case600_AirHVAC   singleZoneAirHVAC(
                              lat=weaDat.lat, designAirFlow=1)
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

    model VAV_SingleZone_drycoil_fan_mix_chilled "Example for SingleZoneVAV with a dry cooling coil, ideal chilled water system, electric heating coil, variable speed fan, and mixing box."
      package MediumAir = Buildings.Media.Air "Buildings library air media package";
      package MediumWater = Buildings.Media.Water "Buildings library air media package";
      HVACSystems.VAV_SingleZone_drycoil_fan_mix_chilled vAV_SingleZone(
        designAirFlow=0.75,
        minAirFlow=0.2*0.75,
        designHeatingEfficiency=0.99,
        designCoolingCOP=3,
        oaFraction=0.2,
        designHeatingCapacity=7000,
        redeclare package MediumAir = MediumAir,
        redeclare package MediumWater = MediumWater,
        designCoolingCapacity=7000,
        supplyAirTempSet=286.15,
        chwsTempSet=279.15,
        sensitivityGainHeat=0.25,
        sensitivityGainCool=0.25)
        annotation (Placement(transformation(extent={{-40,-10},{0,22}})));
      ThermalEnvelope.Case600_AirHVAC   singleZoneAirHVAC(
          designAirFlow=0.75, lat=weaDat.lat)
        annotation (Placement(transformation(extent={{32,-4},{52,16}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=
            "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos")
        annotation (Placement(transformation(extent={{-100,80},{-80,100}})));
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
        annotation (Line(points={{0,8},{4,8},{14,8},{14,26},{38,26},{38,17}},
                                     color={0,127,255}));
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
        annotation (Line(points={{44,17},{44,24},{18,24},{18,-4},{0,-4}},
                                                                        color={
              0,127,255}));
      connect(weaDat.weaBus, vAV_SingleZone.weaBus) annotation (Line(
          points={{-80,90},{-37,90},{-37,23}},
          color={255,204,51},
          thickness=0.5));
      connect(vAV_SingleZone.fanPower, totalFanEnergy.u) annotation (Line(
            points={{1,20},{8,20},{8,-50},{18,-50}}, color={0,0,127}));
      connect(vAV_SingleZone.heatPower, totalHeatingEnergy.u) annotation (Line(
            points={{1,18},{6,18},{6,-70},{18,-70}}, color={0,0,127}));
      connect(vAV_SingleZone.coolPower, totalCoolingEnergy.u) annotation (Line(
            points={{1,16},{4,16},{4,-90},{18,-90}}, color={0,0,127}));
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
          StopTime=504800,
          Interval=3600,
          Tolerance=1e-06,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_drycoil_fan_mix_chilled;

    model VAV_SingleZone_dxCoil_fan_mix "Example for SingleZoneVAV with a single speed air-cooled DX coil, electric heating coil, variable speed fan, and mixing box."
      extends Modelica.Icons.Example;
      package MediumA = Buildings.Media.Air "Buildings library air media package";
      HVACSystems.VAV_SingleZone_dxCoilSingle_fan_mix
                                 vAV_SingleZone(
        redeclare package Medium = MediumA,
        designAirFlow=0.75,
        minAirFlow=0.2*0.75,
        designHeatingEfficiency=0.99,
        designCoolingCOP=3,
        oaFraction=0.2,
        designHeatingCapacity=7000,
        sensitivityGainHeat=0.25,
        sensitivityGainCool=0.25,
        designCoolingCapacity=7000,
        dxCoilPerformance(sta={
              Buildings.Fluid.HeatExchangers.DXCoils.AirCooled.Data.Generic.BaseClasses.Stage(
                  spe=1,
                  nomVal=
                Buildings.Fluid.HeatExchangers.DXCoils.AirCooled.Data.Generic.BaseClasses.NominalValues(
                    Q_flow_nominal=-7000,
                    COP_nominal=3,
                    SHR_nominal=0.8,
                    m_flow_nominal=0.75),
                  perCur=dxCoilPerformanceCurve)}),
        supplyAirTempSet=286.15)
        annotation (Placement(transformation(extent={{-40,-10},{0,22}})));
      ThermalEnvelope.Case600_AirHVAC   singleZoneAirHVAC(
          designAirFlow=0.75, lat=weaDat.lat)
        annotation (Placement(transformation(extent={{32,-4},{52,16}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=
            "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos")
        annotation (Placement(transformation(extent={{-100,80},{-80,100}})));
      Buildings.Fluid.HeatExchangers.DXCoils.AirCooled.Examples.PerformanceCurves.Curve_II
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
        annotation (Line(points={{0,8},{4,8},{14,8},{14,26},{38,26},{38,17}},
                                     color={0,127,255}));
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
        annotation (Line(points={{44,17},{44,24},{18,24},{18,-4},{0,-4}},
                                                                        color={
              0,127,255}));
      connect(weaDat.weaBus, vAV_SingleZone.weaBus) annotation (Line(
          points={{-80,90},{-37,90},{-37,23}},
          color={255,204,51},
          thickness=0.5));
      connect(vAV_SingleZone.fanPower, totalFanEnergy.u) annotation (Line(
            points={{1,20},{8,20},{8,-50},{18,-50}}, color={0,0,127}));
      connect(vAV_SingleZone.heatPower, totalHeatingEnergy.u) annotation (Line(
            points={{1,18},{6,18},{6,-70},{18,-70}}, color={0,0,127}));
      connect(vAV_SingleZone.coolPower, totalCoolingEnergy.u) annotation (Line(
            points={{1,16},{4,16},{4,-90},{18,-90}}, color={0,0,127}));
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
          StopTime=504800,
          Interval=3600,
          Tolerance=1e-06,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_dxCoil_fan_mix;

    model VAV_SingleZone_drycoil_fan_mix_chiller "Example for SingleZoneVAV with a dry cooling coil, air-cooled chiller, electric heating coil, variable speed fan, and mixing box."
      extends Modelica.Icons.Example;
      package MediumAir = Buildings.Media.Air "Buildings library air media package";
      package MediumWater = Buildings.Media.Water "Buildings library air media package";
      HVACSystems.VAV_SingleZone_drycoil_fan_mix_chiller vAV_SingleZone(
        designAirFlow=0.75,
        minAirFlow=0.2*0.75,
        designHeatingEfficiency=0.99,
        oaFraction=0.2,
        designHeatingCapacity=7000,
        redeclare package MediumAir = MediumAir,
        redeclare package MediumWater = MediumWater,
        designCoolingCapacity=7000,
        sensitivityGainHeat=0.25,
        sensitivityGainCool=0.25,
        supplyAirTempSet=286.15,
        chwsTempSet=279.15)
        annotation (Placement(transformation(extent={{-40,-10},{0,22}})));
      ThermalEnvelope.Case600_AirHVAC   singleZoneAirHVAC(
          designAirFlow=0.75, lat=weaDat.lat)
        annotation (Placement(transformation(extent={{32,-4},{52,16}})));
      Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
          computeWetBulbTemperature=false, filNam=
            "modelica://Buildings/Resources/weatherdata/DRYCOLD.mos")
        annotation (Placement(transformation(extent={{-100,80},{-80,100}})));
      Modelica.Blocks.Continuous.Integrator totalFanEnergy
        annotation (Placement(transformation(extent={{20,-40},{40,-20}})));
      Modelica.Blocks.Continuous.Integrator totalHeatingEnergy
        annotation (Placement(transformation(extent={{20,-60},{40,-40}})));
      Modelica.Blocks.Continuous.Integrator totalCoolingEnergy
        annotation (Placement(transformation(extent={{20,-80},{40,-60}})));
      Modelica.Blocks.Math.Sum totalHVACEnergy(nin=4)
        annotation (Placement(transformation(extent={{60,-80},{80,-60}})));
      Modelica.Blocks.Continuous.Integrator totalPumpEnergy
        annotation (Placement(transformation(extent={{20,-100},{40,-80}})));
    equation
      connect(weaDat.weaBus, singleZoneAirHVAC.weaBus) annotation (Line(
          points={{-80,90},{-26,90},{33,90},{33,16.4}},
          color={255,204,51},
          thickness=0.5));
      connect(vAV_SingleZone.supplyAir, singleZoneAirHVAC.supplyAir)
        annotation (Line(points={{0,8},{4,8},{14,8},{14,26},{38,26},{38,17}},
                                     color={0,127,255}));
      connect(singleZoneAirHVAC.zoneMeanAirTemperature, vAV_SingleZone.Tmea)
        annotation (Line(points={{53,6},{60,6},{70,6},{70,-16},{-64,-16},{-64,6},
              {-42,6}},         color={0,0,127}));
      connect(singleZoneAirHVAC.TcoolSetpoint, vAV_SingleZone.TcoolSetpoint)
        annotation (Line(points={{53,-2},{62,-2},{62,-14},{-60,-14},{-60,13.8},
              {-42,13.8}}, color={0,0,127}));
      connect(singleZoneAirHVAC.TheatSetpoint, vAV_SingleZone.TheatSetpoint)
        annotation (Line(points={{53,0},{64,0},{64,-12},{-54,-12},{-54,19},{-42,
              19}}, color={0,0,127}));
      connect(singleZoneAirHVAC.returnAir, vAV_SingleZone.returnAir[1])
        annotation (Line(points={{44,17},{44,24},{18,24},{18,-4},{0,-4}},
                                                                        color={
              0,127,255}));
      connect(weaDat.weaBus, vAV_SingleZone.weaBus) annotation (Line(
          points={{-80,90},{-37,90},{-37,23}},
          color={255,204,51},
          thickness=0.5));
      connect(vAV_SingleZone.fanPower, totalFanEnergy.u) annotation (Line(
            points={{1,20},{10,20},{10,-30},{18,-30}},
                                                     color={0,0,127}));
      connect(vAV_SingleZone.heatPower, totalHeatingEnergy.u) annotation (Line(
            points={{1,18},{8,18},{8,-50},{18,-50}}, color={0,0,127}));
      connect(vAV_SingleZone.coolPower, totalCoolingEnergy.u) annotation (Line(
            points={{1,16},{6,16},{6,-70},{18,-70}}, color={0,0,127}));
      connect(totalFanEnergy.y, totalHVACEnergy.u[1]) annotation (Line(points={{41,-30},
              {48,-30},{48,-71.5},{58,-71.5}},                color={0,0,127}));
      connect(totalHeatingEnergy.y, totalHVACEnergy.u[2]) annotation (Line(
            points={{41,-50},{41,-70.5},{58,-70.5}},
                                                   color={0,0,127}));
      connect(totalCoolingEnergy.y, totalHVACEnergy.u[3]) annotation (Line(
            points={{41,-70},{50,-70},{50,-69.5},{58,-69.5}},       color={0,0,
              127}));
      connect(totalPumpEnergy.y, totalHVACEnergy.u[4]) annotation (Line(points=
              {{41,-90},{48,-90},{48,-68.5},{58,-68.5}}, color={0,0,127}));
      connect(totalPumpEnergy.u, vAV_SingleZone.pumpPower) annotation (Line(
            points={{18,-90},{4,-90},{4,14},{1,14}}, color={0,0,127}));
      annotation (
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        experiment(
          StopTime=504800,
          Interval=3600,
          Tolerance=1e-06,
          __Dymola_Algorithm="Radau"));
    end VAV_SingleZone_drycoil_fan_mix_chiller;

    model FMI
      "Same as Examples.VAV_SingleZone_drycoil_fan_mix_chiller, but using FMI export to decouple HVAC system from thermal envelope."
      extends Modelica.Icons.Example;
      package MediumAir = Buildings.Media.Air "Buildings library air media package";
      package MediumWater = Buildings.Media.Water "Buildings library air media package";
      HVACSystems.FMI_SingleZoneVAVWithChiller fMI_SingleZoneVAVWithChiller(
        designAirFlow=0.75,
        minAirFlow=0.2*0.75,
        oaFraction=0.2,
        designHeatingCapacity=7000,
        designHeatingEfficiency=0.99,
        designCoolingCapacity=7000,
        sensitivityGainHeat=0.25,
        sensitivityGainCool=0.25,
        redeclare package Medium = MediumAir,
        redeclare package MediumWater = MediumWater,
        supplyAirTempSet=286.15,
        chwsTempSet=279.15)
        annotation (Placement(transformation(extent={{-60,-14},{-28,18}})));
      ThermalEnvelope.FMI_Case600_AirHVAC fMI_Case600_AirHVAC(
        nPorts=2,
        designAirFlow=0.75,
        redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{20,-14},{52,18}})));
    equation
      connect(fMI_SingleZoneVAVWithChiller.fluPor, fMI_Case600_AirHVAC.fluPor)
        annotation (Line(points={{-27,16},{-16,16},{19,16}}, color={0,0,255}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end FMI;

    model FMI_T_X_Only
      "Same as Examples.VAV_SingleZone_drycoil_fan_mix_chiller, but reading measured thermal zone temperature and water vapor from file."
      extends Modelica.Icons.Example;
      package MediumAir = Buildings.Media.Air "Buildings library air media package";
      package MediumWater = Buildings.Media.Water "Buildings library air media package";
      HVACSystems.FMI_SingleZoneVAVWithChiller fMI_SingleZoneVAVWithChiller(
        designAirFlow=0.75,
        minAirFlow=0.2*0.75,
        oaFraction=0.2,
        designHeatingCapacity=7000,
        designHeatingEfficiency=0.99,
        designCoolingCapacity=7000,
        sensitivityGainHeat=0.25,
        sensitivityGainCool=0.25,
        redeclare package Medium = MediumAir,
        redeclare package MediumWater = MediumWater,
        supplyAirTempSet=286.15,
        chwsTempSet=279.15)
        annotation (Placement(transformation(extent={{-60,-14},{-28,18}})));
      ThermalEnvelope.FMI_Case600_AirHVAC_TOnly
                                          fMI_Case600_AirHVAC(
        nPorts=2, redeclare package Medium = MediumAir)
        annotation (Placement(transformation(extent={{20,-14},{52,18}})));
    equation
      connect(fMI_SingleZoneVAVWithChiller.fluPor, fMI_Case600_AirHVAC.fluPor)
        annotation (Line(points={{-27,16},{-16,16},{19,16}}, color={0,0,255}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end FMI_T_X_Only;
  end Examples;

  package Icons

    model Example_Broken
      annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Ellipse(lineColor={127,0,0},
                    fillColor={255,255,255},
                    fillPattern=FillPattern.Solid,
                    extent={{-100,-100},{100,100}}), Text(
              extent={{-100,100},{100,-80}},
              lineColor={127,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid,
              textString="X",
              textStyle={TextStyle.Bold})}), Diagram(coordinateSystem(
              preserveAspectRatio=false)));
    end Example_Broken;
    annotation (Icon(graphics={
          Rectangle(
            lineColor={200,200,200},
            fillColor={248,248,248},
            fillPattern=FillPattern.HorizontalCylinder,
            extent={{-100,-100},{100,100}},
            radius=25.0),
          Rectangle(
            lineColor={128,128,128},
            extent={{-100,-100},{100,100}},
            radius=25.0),                    Polygon(
              origin={-8.167,-17},
              fillColor={128,128,128},
              pattern=LinePattern.None,
              fillPattern=FillPattern.Solid,
              points={{-15.833,20.0},{-15.833,30.0},{14.167,40.0},{24.167,20.0},{
                  4.167,-30.0},{14.167,-30.0},{24.167,-30.0},{24.167,-40.0},{-5.833,
                  -50.0},{-15.833,-30.0},{4.167,20.0},{-5.833,20.0}},
              smooth=Smooth.Bezier,
              lineColor={0,0,0}), Ellipse(
              origin={-0.5,56.5},
              fillColor={128,128,128},
              pattern=LinePattern.None,
              fillPattern=FillPattern.Solid,
              extent={{-12.5,-12.5},{12.5,12.5}},
              lineColor={0,0,0})}));
  end Icons;
  annotation (uses(Modelica(version="3.2.2"), Buildings(version="4.0.0")));
end SOEPDemo;
