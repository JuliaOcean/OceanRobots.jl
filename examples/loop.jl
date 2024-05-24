
using Glob, Pluto, Pkg

#lst=glob("*.jl")

for f in lst[3:end]
try
Pluto.activate_notebook_environment(f)
if true
  Pkg.update()
else
  include(f)
end
Pkg.activate()
println("done :"*f)
catch
println("FAIL :"*f)
end
end


