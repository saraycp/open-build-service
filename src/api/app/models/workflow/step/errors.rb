module Workflow::Step::Errors
  extend ActiveSupport::Concern

  class CanNotLinkPackageNotFound < APIError
    setup 404
  end

  class DuplicatePackageError < APIError
    attr_reader :project, :package

    def initialize(project, package)
      super(message)
      @project = project
      @package = package
    end
  end
end
