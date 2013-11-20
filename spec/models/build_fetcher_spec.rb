require 'spec_helper'

describe BuildFetcher do
  let(:build)   { create :build }
  let(:fetcher) { described_class.new build }
  subject { fetcher }

  it { should be }

  context "just created" do
    its(:build)   { should eq build }
    its(:project) { should eq build.project }
  end

  context "(github)" do
    let(:user) { create :user }
    let(:identity) { create :user_identity, :github, user: user }
    before do
      build.project.update! identity: identity
    end

    context "just created" do
      its(:github) { should be }
    end

    context "#fetch_commit_from_github" do
      subject { fetcher.fetch_commit_from_github }

      it "should be success" do
        mock_commit_request
        expect(subject.sha).to     eq '84158c732ff1af3db9775a37a74ddc39f5c4078f'
        expect(subject.message).to eq "Update Rakefile"
        expect(subject.author).to  eq "Dmitry Galinsky"
        expect(subject.author_email).to_not be_blank
        expect(subject.http_url).to_not be_blank
      end

      context "when commit not found" do
        it "should be nil" do
          mock_not_found_commit_request
          expect(subject).to be_nil
        end
      end
    end

    context "#fetch_travis_from_github" do
      subject { fetcher.fetch_travis_from_github }
      before do
        build.sha = "84158c732ff1af3db9775a37a74ddc39f5c4078f"
      end

      it "should be success" do
        mock_contents_request
        expect(subject).to_not be_blank
      end

      context "when not found" do
        it "should be nil" do
          mock_not_found_contents_request
          expect(subject).to be_nil
        end
      end
    end

    context "#create_perform_build_message_using_github" do
      subject { fetcher.create_perform_build_message_using_github }

      context "when success" do
        before do
          mock_commit_request
          mock_contents_request
        end

        it { should be_true }

        %w{ sha message author author_email http_url }.each do |m|
          it "should update build #{m}" do
            expect{ subject }.to change{ build.reload.public_send(m) }
          end
        end

        it "should delivery PerformBuild message" do
          expect {
            subject
          }.to change(BuildsConsumer.messages, :count).by(1)
        end
      end

      context "when cannot retrieve github identity" do
        before do
          mock(fetcher).github { nil }
        end

        it { should be_false }
        it "should fail build" do
          expect{ subject }.to change(build, :status_name).to(:errored)
        end
      end

      context "when cannot retrieve commit" do
        before do
          mock_not_found_commit_request
        end

        it { should be_false }
        it "should fail build" do
          expect{ subject }.to change(build, :status_name).to(:errored)
        end
      end

      context "when cannot update build commit" do
        before do
          mock(fetcher).fetch_commit_from_github{
            Github::BuildFetcher::GithubCommit.new(
              nil, nil, nil, nil, nil
            )
          }
        end

        it { should be_false }
        it "should fail build" do
          expect{ subject }.to change(build, :status_name).to(:errored)
        end
      end

      context "when cannot retrieve travis" do
        before do
          mock_commit_request
          mock_not_found_contents_request
        end

        it { should be_false }
        it "should fail build" do
          expect{ subject }.to change(build, :status_name).to(:errored)
        end
      end
    end

    def mock_commit_request
      commit = read_fixture("github/commit.json")
      stub_request(:get, "https://api.github.com/repos/ci-worker-test-repo/commits/MyString").
         with(:headers => {'Authorization'=>'token MyString'}).
         to_return(:status => 200, :body => commit, headers: {'Content-Type' => 'application/json'})
    end

    def mock_not_found_commit_request
      stub_request(:get, "https://api.github.com/repos/ci-worker-test-repo/commits/MyString").
         with(:headers => {'Authorization'=>'token MyString'}).
         to_return(:status => 404, :body => "{}", headers: {'Content-Type' => 'application/json'})
    end

    def mock_contents_request
      contents = read_fixture("github/contents.json")
      stub_request(:get, "https://api.github.com/repos/ci-worker-test-repo/contents/.travis.yml?ref=84158c732ff1af3db9775a37a74ddc39f5c4078f").
         with(:headers => {'Authorization'=>'token MyString'}).
         to_return(:status => 200, :body => contents, headers: {'Content-Type' => 'application/json'})
    end

    def mock_not_found_contents_request
      stub_request(:get, "https://api.github.com/repos/ci-worker-test-repo/contents/.travis.yml?ref=84158c732ff1af3db9775a37a74ddc39f5c4078f").
         with(:headers => {'Authorization'=>'token MyString'}).
         to_return(:status => 404, :body => "{}", headers: {'Content-Type' => 'application/json'})
    end
  end

end
