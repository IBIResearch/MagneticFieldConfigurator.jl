

function MagneticFieldConfigurator.viewer(system::MagneticFieldSystem)
  fig = Figure()
  ax = Axis3(fig[1,1], xlabel = "x / cm", ylabel = "y / cm", zlabel = "z / cm")

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

  plot!(ax, system.generators)

  if isdefined(Main, :GLMakie)
    display_fig_in_new_window(fig; title="Magnetic Field Viewer")
  else
    display(fig)
  end
  return fig
  #return fig, ax
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