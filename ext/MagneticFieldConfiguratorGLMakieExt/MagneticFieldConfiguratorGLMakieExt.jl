module MagneticFieldConfiguratorGLMakieExt

using MagneticFieldConfigurator, GLMakie

function MagneticFieldConfigurator.display_fig_in_new_window(fig::Figure; title="Viewer")
  GLMakie.activate!(;title)
  display(GLMakie.Screen(), fig)
end

function MagneticFieldConfigurator.close!(fig::Figure)
  if !isempty(fig.scene.current_screens)
    GLMakie.destroy!(fig.scene.current_screens[1])
  end
  return
end

function MagneticFieldConfigurator.changeWindowCloseCallback(window::GLMakie.GLFW.Window, callback)
  GLMakie.GLFW.SetWindowCloseCallback(window, callback)
end

end