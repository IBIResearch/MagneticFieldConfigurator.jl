

function MagneticFieldConfigurator.viewer(system::MagneticFieldSystem)

  fig = Figure(size=(900,700), figure_padding = 10, backgroundcolor = :gray97)

  bbox = system.bbox
  bbmin = minimum(bbox)
  bbmax = maximum(bbox)
  limits = (bbmin[1], bbmax[1], bbmin[2], bbmax[2], bbmin[3], bbmax[3])

  ax = Axis3(fig[1,1], xlabel = "x / cm", ylabel = "y / cm", zlabel = "z / cm", limits=limits)
  cb = Colorbar(fig[1, 2], limits=(0.0,1.0), label="H / mT")

  grid = GridLayout(fig[2, 1:2], tellwidth=false, alignmode = Outside(0,0,0,10))

  plot!(ax, system.generators)
  α = 0.1
  colorsbg = [ c*α + (1-α)*colorant"white" for c in 
              [ibicolors(1),ibicolors(2),ibicolors(3),ibicolors(4)] ]
  α = 0.3
  colorsfg = [ c*α + (1-α)*colorant"white" for c in 
               [ibicolors(1),ibicolors(2),ibicolors(3),ibicolors(4)] ]

  box1 = Box(grid[1,1], cornerradius = 10, color = colorsbg[1], strokecolor = colorsfg[1], strokewidth = 2)
  box2 = Box(grid[1,2], cornerradius = 10, color = colorsbg[2], strokecolor = colorsfg[2], strokewidth = 2)
  box3 = Box(grid[1,3], cornerradius = 10, color = colorsbg[3], strokecolor = colorsfg[3], strokewidth = 2) 

  tbGridSize = Textbox(fig, stored_string = "11 x 11 x 11", validator = r"\s*\d+\s*x\s*\d+\s*x\s*\d+\s*")
  tbGridFov = Textbox(fig, stored_string = "0.1 x 0.1 x 0.1", validator = r"\s*\d+(\.\d+)?\s*x\s*\d+(\.\d+)?\s*x\s*\d+(\.\d+)?\s*" )
  tbGridCenter = Textbox(fig, stored_string = "0.0 x 0.0 x 0.0", validator = r"\s*\d+(\.\d+)?\s*x\s*\d+(\.\d+)?\s*x\s*\d+(\.\d+)?\s*" )

  btnShowSliceX = Toggle(fig, active=true)
  btnShowSliceY = Toggle(fig, active=true)
  btnShowSliceZ = Toggle(fig, active=true)



  grid1 = grid!([1, 1] => Label(fig, "Grid Size:"), [1, 2] => tbGridSize,
                [2, 1] => Label(fig, "Grid Fov:"), [2, 2] => tbGridFov,
                [3, 1] => Label(fig, "Grid Center:"), [3, 2] => tbGridCenter,
                [1, 3] => Label(fig, "Slice X:"), [1, 4] => btnShowSliceX,
                [2, 3] => Label(fig, "Slice Y:"), [2, 4] => btnShowSliceY,
                [3, 3] => Label(fig, "Slice Z:"), [3, 4] => btnShowSliceZ,
                alignmode = Outside(5))
                grid[1,1] = grid1 
  sg = SliderGrid(
    grid1[1:3, 5],
    (label = "x", range = 1:11,  startvalue = 5),
    (label = "y", range = 1:11,  startvalue = 5),
    (label = "z", range = 1:11,  startvalue = 5),
    width = 350,
    tellheight = false)

  on(tbGridSize.stored_string) do s
    gridsize = parse.(Int, split(tbGridSize.stored_string[], "x"))
    for d=1:3
      sg.sliders[d].range[] = 1:gridsize[d]
    end
  end

                  
  rowgap!(grid1, 10); colgap!(grid1, 10)

  tbCurrents = Textbox(fig, stored_string = join(system.source.currents, ","), 
                        validator = r"^\s*-?\d+(\.\d+)?(\s*,\s*-?\d+(\.\d+)?)*\s*$" )


  grid2 = grid!([1, 1] =>  Label(fig,"Currents"), [1, 2] => tbCurrents, 
                alignmode = Outside(5))
  grid[1,2] = grid2
  rowgap!(grid2, 10); colgap!(grid2, 10)
  colgap!(grid, 10)

  btnCalc = Button(fig, label = "Calculate Field")
  grid3 = grid!([1, 1] => btnCalc, 
                alignmode = Outside(5))
  grid[1,3] = grid3
  rowgap!(grid3, 10); colgap!(grid3, 10)
  colgap!(grid, 10)


  rowgap!(fig.layout, Relative(0.01))


  on(btnCalc.clicks) do n
    gridsize = parse.(Int, split(tbGridSize.stored_string[], "x"))
    gridfov = parse.(Float64, split(tbGridFov.stored_string[], "x"))
    gridcenter = parse.(Float64, split(tbGridCenter.stored_string[], "x"))
    Δ = gridfov ./ (gridsize .- 1)
    minFov = gridcenter .- gridfov./2 .+ Δ./2
    maxFov = gridcenter .+ gridfov./2 .- Δ./2

    empty!(ax)
    plot!(ax, system.generators)

    currents = parse.(Float64, split(tbCurrents.stored_string[], ","))
    if length(currents) == length(system.source.currents)
      system.source.currents .= currents
    else
      println("Number of currents does not match number of coils")
    end
    

    current!(system.source, system.source.currents)

    z_ = range(minFov[3],maxFov[3],length=gridsize[3])
    y_ = range(minFov[1],maxFov[1],length=gridsize[1])
    x_ = range(minFov[1],maxFov[1],length=gridsize[1])

    maxfield = 0.0
    
    if btnShowSliceX.active[]
      fieldXZ = [norm(system.generators[x,gridcenter[2],z]) for z in z_, x in x_]
      maxfield = max(maximum(fieldXZ), maxfield)
    end

    if btnShowSliceY.active[]
      fieldYZ = [norm(system.generators[gridcenter[1],y,z]) for z in z_, y in y_]
      maxfield = max(maximum(fieldYZ), maxfield)
    end

    if btnShowSliceZ.active[]
      fieldXY = [norm(system.generators[x,y,gridcenter[3]]) for y in y_, x in x_]
      maxfield = max(maximum(fieldXY), maxfield)
    end

    if btnShowSliceX.active[]
      plXZ = heatmap!(ax, x_, z_, fieldXZ'; transformation=(:xz, y_[sg.sliders[2].value[]]),  
        colorrange = (0,maxfield) )
    end
    
    if btnShowSliceY.active[]
      plYZ = heatmap!(ax, y_, z_, fieldYZ'; transformation=(:yz, x_[sg.sliders[1].value[]]),  
        colorrange = (0,maxfield) )
    end

    if btnShowSliceZ.active[]
      plXY = heatmap!(ax, x_, y_, fieldXY'; transformation=(:xy, z_[sg.sliders[3].value[]]),  
        colorrange = (0,maxfield) )
    end
    
    #empty!(fig[1, 2])
    cb.limits = (0, maxfield)
  end

  if isdefined(Main, :GLMakie)
    display_fig_in_new_window(fig; title="Magnetic Field Viewer")
  else
    display(fig)
  end
  return fig
  #return fig, ax
end

function plotFields(fig, ax, system::MagneticFieldSystem)

  x_ = range(-0.15,0.15,length=25)
  y_ = range(-0.15,0.15,length=20)

  current!(system.source, system.source.currents)

  field = zeros(3, length(y_), length(x_))
  absfield = zeros(length(y_), length(x_))
  for i=1:length(y_)
    for j=1:length(x_)
      field[:,i,j] .= system.generators[x_[j],y_[i],0.0]
      absfield[i,j] = norm(field[:,i,j])
    end
  end
  maxfield = maximum(absfield)*0.1

  pl2 = heatmap!(ax, x_, y_, absfield'; transformation=(:xy, 0.0),  
                    colorrange = (0,maxfield) )

  arrows!(ax, x_[1:2:end], y_[1:2:end], field[1,1:2:end,1:2:end]'./maximum(absfield), 
          field[2,1:2:end,1:2:end]'./maximum(absfield), 
          arrowsize = 10.5, lengthscale = 0.3, color=:white, linewidth=5)
end


#=export MMRViewer

function MMRViewer(data::MMRMeasurement; filename="")
  fig = Figure(size=(1200,600), figure_padding = 10, backgroundcolor = :gray97)

  v = MMRViewer(data, fig; showFrameSlider=true)

  #fig[2,1] = grid!(hcat(Label(fig, "Frame:"), v.frameSlider, v.btnShowTx, 
  #           v.btnAutoLimitY, v.btnAutoLimitYAll), tellwidth=false)

  grid = GridLayout(fig[2, 1], tellwidth=false, alignmode = Outside(0,0,0,10))

  α = 0.1
  colorsbg = [ c*α + (1-α)*colorant"white" for c in 
              [ibicolors(1),ibicolors(2),ibicolors(3),ibicolors(4)] ]
  α = 0.3
  colorsfg = [ c*α + (1-α)*colorant"white" for c in 
               [ibicolors(1),ibicolors(2),ibicolors(3),ibicolors(4)] ]

  #box1 = Box(grid[1,1], cornerradius = 10, color = colorsbg[1], strokecolor = colorsfg[1], strokewidth = 2)
  #box2 = Box(grid[1,2], cornerradius = 10, color = colorsbg[4], strokecolor = colorsfg[4], strokewidth = 2)  
  box1 = Box(grid[1,1], cornerradius = 10, color = (:teal, 0.1), strokecolor = (:teal, 0.3), strokewidth = 2)
  box2 = Box(grid[1,2], cornerradius = 10, color = (:blue, 0.1), strokecolor = (:blue, 0.3), strokewidth = 2)  

  grid1 = grid!([1, 1] => Label(fig, "Frame:"), [1, 2] => v.frameSlider,
                alignmode = Outside(5))
  grid[1,1] = grid1                   
  rowgap!(grid1, 10); colgap!(grid1, 10)

  grid2 = grid!([1, 1] => Label(fig, "ShowRxDuringTx:"), [1, 2] => v.btnShowTx,
                [2, 1] => Label(fig, "DC Removal:"), [2, 2] => v.btnDCRemoval,
                [1, 3] => Label(fig, "AutoLimitY:"), [1, 4] => v.btnAutoLimitY,
                [2, 3] => Label(fig, "AutoLimitYAll:"), [2, 4] => v.btnAutoLimitYAll,
                [1, 5] => v.btnOnlineTracking,
                [2, 5] => v.btnShowFieldSystem,
                alignmode = Outside(5))
  grid[1,2] = grid2
  rowgap!(grid2, 10); colgap!(grid2, 10)
  colgap!(grid, 10)


  rowgap!(fig.layout, Relative(0.01))

  #display(fig)
  if isdefined(Main, :GLMakie)
    display_fig_in_new_window(fig; title="MMRViewer: $filename")
  else
    display(fig)
  end
  return v
end

function MMRViewer(filename::String)
  data = load(filename)
  return MMRViewer(data; filename)
end

=#