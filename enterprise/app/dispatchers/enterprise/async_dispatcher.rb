module Enterprise::AsyncDispatcher
  def listeners
    super + [
      AIAgentListener.instance
    ]
  end
end
