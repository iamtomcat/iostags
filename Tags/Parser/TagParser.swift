import Foundation

open class TagParser {
  private var tagHandler: TagsDataSource

  private(set) var commands = [CommandProtocol]()

  private func removeCommandPrefix(_ command: String) -> String? {
    return command.isCommand ? String(command.dropFirst()) : nil
  }

  private func getCommandBy(Name name: String) -> Tag? {
    let type = commands.filter { value -> Bool in
      value.suggestionTitle.hasPrefix(name)
    }.first
    return Tag.command("", type)
  }

  private func handleCommands(_ command: String) -> [Tag]? {
    guard let command = removeCommandPrefix(command)
      else { return nil }

    if command.isEmpty {
      return commands.map {
        Tag.command($0.suggestionTitle, $0)
      }.flatMap { $0 }
    }

    if let command = getCommandBy(Name: command.lowercased()) {
      return [command]
    }
    return nil
  }

  open func register(Command command: CommandProtocol) {
    commands.append(command)
  }

  private func setupDefaultCommands() {
    let commands: [CommandProtocol] = [Reminder(), DueDate()]
    for command in commands {
      self.register(Command: command)
    }
  }

  private func getTagsThatMatch(Text text: String) -> [Tag] {
    let tags: [Tag] = tagHandler.getTagsBy(Prefix: text.lowercased()).map { tag -> Tag in
      return Tag.tag(tag)
    }
    return tags
  }

  open var currentTags = [Tag]()
  open func parse(_ text: String) -> [Tag] {
    if let tags = handleCommands(text) {
      currentTags = tags
    } else {
      currentTags = getTagsThatMatch(Text: text)
    }
    return currentTags
  }

  public init(tags: TagsDataSource) {
    self.tagHandler = tags
    setupDefaultCommands()
  }
}