class Workflow::Step::LinkPackageStep < ::Workflow::Step
  validates :source_package_name, presence: true

  def call(options = {})
    return unless valid?

    linked_package = find_or_create_linked_package
    add_or_update_branch_request_file(package: linked_package)
    workflow_filters = options.fetch(:workflow_filters, {})
    create_or_update_subscriptions(linked_package, workflow_filters)

    workflow_repositories(target_project_name, workflow_filters).each do |repository|
      # TODO: Fix n+1 queries
      workflow_architectures(repository, workflow_filters).each do |architecture|
        # We cannot report multibuild flavors here... so they will be missing from the initial report
        SCMStatusReporter.new({ project: target_project_name, package: target_package_name, repository: repository.name, arch: architecture.name },
                              scm_extractor_payload, @token.scm_token).call
      end
    end

    linked_package
  end

  def source_package_name
    step_instructions['source_package']
  end

  private

  def target_project
    Project.find_by(name: target_project_name)
  end

  def source_package
    Package.find_by_project_and_name(source_project_name, source_package_name)
  end

  def special_package_file_content
    <<~XML
      <services>
        <service name="format_spec_file" mode="localonly"/>
      </services>
    XML
  end

  def create_project_and_package
    check_source_access

    if target_package.present?
      raise Workflow::Step::Errors::DuplicatePackageError.new(target_project_name, target_package_name), "Can not link package. The package #{target_package_name} already exists."
    end

    if target_project.nil?
      project = Project.create!(name: target_project_name)
      project.commit_user = User.session
      project.relationships.create!(user: User.session, role: Role.find_by_title('maintainer'))
      project.store
    end

    target_project.packages.create(name: target_package_name)

    # NOTE: the next lines are a temporary fix the allow the service to run in a linked package. A project service is needed.
    return if Package.find_by_project_and_name(target_project, '_project')

    special_package = target_project.packages.create(name: '_project')
    special_package.save_file({ file: special_package_file_content, filename: '_service' })
  end

  def find_or_create_linked_package
    return target_package if validator.updated_pull_request? && target_package.present?

    create_project_and_package
    link
  end

  def check_source_access
    return if remote_source?

    options = { use_source: false, follow_project_links: true, follow_multibuild: true }

    begin
      src_package = Package.get_by_project_and_name(source_project_name, source_package_name, options)
    rescue Package::UnknownObjectError
      raise Workflow::Step::Errors::CanNotLinkPackageNotFound, "Package #{source_project_name}/#{source_package_name} not found, it could not be linked."
    end

    Pundit.authorize(@token.user, src_package, :link?)
  end

  def link_xml(opts = {})
    # "<link package=\"foo\" project=\"bar\" />"
    Nokogiri::XML::Builder.new { |x| x.link(opts) }.doc.root.to_s
  end

  def link
    Backend::Api::Sources::Package.write_link(target_project_name,
                                              target_package_name,
                                              @token.user,
                                              link_xml(project: source_project_name, package: source_package_name))

    target_package
  end
end

# TODO: triger service is not working as expected for linked packages.
# Changes introduced in a PR are not reflected in source code of target package.
