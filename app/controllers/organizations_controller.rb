class OrganizationsController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_organization, except: [:index, :new, :create]
  before_action :scope_projects, only: [:show, :update]
  before_action :scope_issues, only: [:show, :update]
  before_action :enforce_view_permissions, except: [:index, :new, :create]
  before_action :enforce_management_permissions, only: [:edit, :update]

  breadcrumb "Organizations", :organizations_path

  def index
    @organizations = Role.where(
      "account_id = ? AND organization_id IS NOT NULL AND is_owner = ?",
      current_account.id,
      true
    ).includes(:organization).map(&:organization).sort_by(&:name)
  end

  def new
    @organization = Organization.new(account_id: current_account.id)
  end

  def create
    @organization = Organization.new(organization_params.merge(account_id: current_account.id))
    if @organization.save
      Role.create(organization_id: @organization.id, account_id: current_account.id, is_owner: true)
      redirect_to @organization
    else
      flash[:error] = @organization.errors.full_messages
      render :new
    end
  end

  def show
    breadcrumb @organization.name, organization_path(@organization)
    if @organization.projects.count > 12
      @page_index = @organization.projects.order('name ASC').pluck(:name).map(&:first).uniq
      @current_index = params[:page] || @page_index.first
      @previous_index = @page_index[@page_index.index(@current_index) - 1]
      @next_index = @page_index[@page_index.index(@current_index) - 1]
      @projects = @organization.projects.starting_with(@current_index)
    else
      @projects = @organization.projects.order('name ASC')
    end
  end

  def edit
    breadcrumb @organization.name, organization_path(@organization)
  end

  def update
    @organization.update(organization_params)
    render :show
  end

  def github_auth_token
    breadcrumb @organization.name, organization_path(@organization)
    @token = current_account.github_token
  end

  def import_projects_from_github
    breadcrumb @organization.name, organization_path(@organization)
    current_account.update_github_token(params[:token])
    results = GithubImportService.new(current_account, @organization).import_projects
    if results[:success]
      flash[:info] = "Successfully imported #{results[:count]} project(s)."
    else
      flash[:error] = "Could not import projects: #{results[:error]}."
    end
    redirect_to organization_path(@organization)
  end

  def gitlab_auth_token
    breadcrumb @organization.name, organization_path(@organization)
    @token = current_account.gitlab_token
  end

  def import_projects_from_gitlab
    current_account.update_gitlab_token(params[:token])
    results = GitlabImportService.new(current_account, @organization).import_projects
    if results[:success]
      flash[:info] = "Successfully imported #{results[:count]} project(s). #{results[:error]}"
    else
      flash[:error] = "Could not import projects: #{results[:error]}."
    end
    redirect_to organization_path(@organization)
  end

  def moderators
    breadcrumb @organization.name, organization_path(@organization)
    @invitation = Invitation.new(organization_id: @organization.id)
    @invitations = @organization.invitations
    @moderators = @organization.moderators
  end

  def remove_moderator
    Role.where(account_id: params[:account_id], organization_id: @organization.id).destroy_all
    redirect_to organization_moderators_path
  end

  private

  def enforce_management_permissions
    render_forbidden && return unless current_account.can_manage_organization?(@organization)
  end

  def enforce_view_permissions
    render_forbidden && return unless current_account.can_view_organization?(@organization)
  end

  def organization_params
    params.require(:organization).permit(
      :name,
      :url,
      :coc_url,
      :description,
      :remote_org_name,
      :accept_issues_by_email
    )
  end

  def scope_organization
    @organization = Organization.find_by(slug: params[:slug]) || Organization.find_by(slug: params[:organization_slug])
    render_not_found unless @organization
  end

  def scope_issues
    @issues = ProjectIssue.issues_for_organization(@organization)
  end

  def scope_projects
    @projects = @organization.projects.order("name ASC")
  end

end
