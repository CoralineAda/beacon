# require "rails_helper"
#
# describe "the directory", type: :system do
#
#   let(:maintainer) { FactoryBot.create(:danielle) }
#   let!(:project_1) do
#     FactoryBot.create(
#       :project,
#       name: "Beacon Project",
#       account: maintainer,
#       public: true
#     )
#   end
#
#   let!(:project_2) do
#     FactoryBot.create(
#       :project,
#       name: "Contributor Covenant",
#       account: maintainer,
#       public: true
#     )
#   end
#
#   let!(:project_3) do
#     FactoryBot.create(
#       :project,
#       name: "Zellophane",
#       organization_name: "ZebraCom",
#       account: maintainer,
#       public: true
#     )
#   end
#
#   before do
#     allow_any_instance_of(Project)
#       .to receive(:publicly_accessible?)
#       .and_return(true)
#   end
#
#   it "allows search by project name" do
#     login_as(maintainer, scope: :account)
#     visit root_path
#     fill_in "q", with: "contr"
#     click_on "Search"
#     expect(page).to have_content("Contributor Covenant")
#   end
#
#   it "displays a project page" do
#     visit directory_project_path(project_1)
#     expect(page).to have_content("View code of conduct")
#   end
#
# end
