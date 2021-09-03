model DepTest
  Real x(start=0.0, fixed=true); // State
  discrete Real l(start = 1.0, fixed = true); // Local
  discrete output Real o(start = 2.0, fixed = true); // Output
equation
  der(x) = 0.001;
algorithm
  when time > l + x then
    l := pre(l) + 1.0;
  end when;
  when time > o + x then
    o := pre(o) + 2.0;
  end when;
annotation( experiment(StartTime=0, StopTime=5, Tolerance=1e-4) );
end DepTest;
