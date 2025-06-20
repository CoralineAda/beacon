# require "rails_helper"
#
# describe "the registration process", type: :system do
#
#   before do
#     allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { true }
#     allow_any_instance_of(Accounts::RegistrationsController).to receive(:verify_recaptcha).and_return(true)
#   end
#
#   it "rejects junk emails" do
#     allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { false }
#     visit new_account_registration_path
#     fill_in "Email", with: "donnie@madeupdomainxxx.com"
#     fill_in "Password", with: "passwordpassword"
#     fill_in "Password confirmation", with: "passwordpassword"
#     click_button "Sign Up"
#     expect(page).to have_content "Email is invalid"
#   end
#
#   it "rejects duplicate emails" do
#     allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { true }
#     account = FactoryBot.create(:account, email: "donnie@gmail.com")
#     account.confirmed_at = Time.now
#     account.save
#     visit new_account_registration_path
#     fill_in "Email", with: "donnie+1@gmail.com"
#     fill_in "Password", with: "passwordpassword"
#     fill_in "Password confirmation", with: "passwordpassword"
#     click_button "Sign Up"
#     expect(page).to have_content "Email address must be unique"
#   end
#
# end
#
# describe "the signin process", type: :system do
#
#   let(:script_kiddie) { FactoryBot.create(:donnie) }
#
#   it "locks an account after 3 failed login attempts" do
#     visit new_account_session_path
#     fill_in "Email", with: script_kiddie.email
#     fill_in "Password", with: "wrongpassword"
#     click_button "Sign In"
#     expect(page).to have_content "Invalid Email or password."
#     fill_in "Email", with: script_kiddie.email
#     fill_in "Password", with: "wrongpassword2"
#     click_button "Sign In"
#     expect(page).to have_content "Invalid Email or password."
#     fill_in "Email", with: script_kiddie.email
#     fill_in "Password", with: "wrongpassword3"
#     click_button "Sign In"
#     expect(page).to have_content "Your account is locked."
#   end
#
# end
#
# describe "reporting a project for abuse" do
#
#   let(:maintainer) { FactoryBot.create(:danielle) }
#   let(:spammer) { FactoryBot.create(:michael) }
#   let(:project) { FactoryBot.create(:project, account: maintainer) }
#   let(:abuse_reports) do
#     Array.new(
#       ENV.fetch('MAX_ABUSE_REPORTS_PER_DAY').to_i,
#       AbuseReport.new(aasm_state: "submitted", project: Project.new)
#     )
#   end
#
#   it "requires a logged in user" do
#     visit new_abuse_report_path
#     expect(page).to have_content "You need to sign in or sign up before continuing"
#   end
#
#   context "with abuse report throttling" do
#
#     before do
#       allow_any_instance_of(AbuseReportSubject).to receive(:project).and_return(project)
#       allow(spammer).to receive_message_chain("abuse_reports.submitted").and_return(abuse_reports)
#     end
#
#     it "prevents too many abuse reports from the same account" do
#       login_as(spammer, scope: :account)
#       visit new_abuse_report_path
#       expect(page).to have_content("Resource Unavailable") # 403
#     end
#   end
#
#   context "when an abuse report for a project already exists" do
#     before do
#       AbuseReport.create(project: project)
#     end
#
#     it "doesn't spam admins with multiple abuse reports" do
#       login_as(spammer, scope: :account)
#       visit new_abuse_report_path(project_slug: project.slug)
#       fill_in "Explanation", with: "This project sucks."
#       click_button "Report Project"
#       expect(page).to have_content("Your report has been sent to Beacon administrative staff for review.")
#       expect(AbuseReport.count).to eq(1)
#     end
#   end
#
# end
#
# describe "bad project maintainer blocking an account" do
#
#   context "when an account is already marked for admin review" do
#
#     let(:bad_maintainer) { FactoryBot.create(:michael) }
#     let(:innocent_reporter) { FactoryBot.create(:exene) }
#     let(:project) { FactoryBot.create(:project, account: bad_maintainer) }
#
#     before do
#       allow(bad_maintainer).to receive(:submitted_abuse_report_for?).and_return(true)
#       Role.create(account_id: bad_maintainer.id, project_id: project.id, is_owner: true)
#     end
#
#     xit "doesn't spam admins wtih multiple abuse reports" do
#       login_as(bad_maintainer, scope: :account)
#       visit project_respondent_path(project_slug: project, id: innocent_reporter.id)
#       fill_in "Reason", with: "Pure malice!"
#       check "account_project_block_report_for_abuse"
#       click_button "Block"
#       expect(AbuseReport.count).to eq(1)
#     end
#   end
#
# end
#
# describe "any user (signed in or not) using the general contact form" do
#
#   xit "doesn't allow a junk email address" do
#     allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { false }
#     visit new_contact_message_path
#     fill_in "Your email address", with: "donnie@madeupdomainxxx.com"
#     fill_in "Message", with: "I'm going to speak my mind and you'll never be able to reply!"
#     click_button "Send Message"
#     expect(page).to have_hidden_content "email is invalid"
#   end
#
#   context "more than the maximum number of times in 24 hours" do
#
#     before do
#       allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { true }
#       allow(ContactMessage)
#         .to receive_message_chain(:past_24_hours, :for_ip)
#         .and_return(Array.new(ENV.fetch('MAX_GENERAL_CONTACTS_PER_DAY').to_i, ContactMessage.new))
#     end
#
#     it "is blocked by rate limiting" do
#       visit new_contact_message_path
#       fill_in "Your email address", with: "donnie@realdomain.com"
#       fill_in "Message", with: "I'm gonna bomb your inbox!"
#       click_button "Send Message"
#       expect(page).to have_content "The limit of messages you can send has been reached."
#     end
#
#   end
#
# end
#
# describe "a reporter or respondent adding an issue comment" do
#
#   context "for a moderator who has unread notifications from the user on this issue" do
#
#     let(:maintainer) { FactoryBot.create(:danielle) }
#     let(:project) { FactoryBot.create(:project, account: maintainer) }
#     let(:reporter) { FactoryBot.create(:exene) }
#     let(:issue) { FactoryBot.create(:issue, project_id: project.id, reporter_id: reporter.id) }
#
#     before do
#       ActionMailer::Base.deliveries = []
#       Role.create(account_id: maintainer.id, project_id: project.id, is_owner: true)
#     end
#
#     it "sends an email notification only once" do
#       Resque.inline do
#         login_as(reporter, scope: :account)
#         visit issue_path(issue, project_slug: project.slug)
#         fill_in "issue_comment_text", with: "Trigger a notification"
#         click_button "Send Message"
#         expect(ActionMailer::Base.deliveries.size).to eq(1)
#         fill_in "issue_comment_text", with: "Trigger a notification"
#         click_button "Send Message"
#         expect(ActionMailer::Base.deliveries.size).to eq(1)
#       end
#     end
#
#   end
# end
#
# describe "a malicious reporter attempting to open an issue" do
#
#   context "after submitting the maximum number of reports per day" do
#
#     let(:maintainer) { FactoryBot.create(:danielle) }
#     let!(:project) { FactoryBot.create(:project, account: maintainer) }
#     let(:reporter) { FactoryBot.create(:michael) }
#
#     before do
#       ENV.fetch('MAX_ISSUES_PER_DAY').to_i.times do
#         FactoryBot.create(:issue, reporter_id: reporter.id, project_id: project.id)
#       end
#     end
#
#     it "is prevented from opening new issues" do
#       login_as(reporter, scope: :account)
#       visit directory_project_path(slug: project.slug)
#       expect(page.has_content?("You cannot open an issue on this project at this time.")).to be_truthy
#     end
#
#   end
#
# end
