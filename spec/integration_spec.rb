require 'active_support/all'
require 'mumukit/bridge'

describe 'runner' do
  let(:bridge) { Mumukit::Bridge::Runner.new('http://localhost:4567') }

  before(:all) do
    @pid = Process.spawn 'rackup -p 4567', err: '/dev/null'
    sleep 3
  end
  after(:all) { Process.kill 'TERM', @pid }

  it 'prevents malicious net related code' do
    response = bridge.run_tests!(test: 'var http = require("http"); describe("foo", () => it("bar", (done) => foo(http, done)).timeout(6000))',
                                 extra: '',
                                 expectations: [],
                                 content: <<-javascript
function foo(http, done) {
  http.get("http://google.com", (res) => done(res)).on('error', (e) => done(e))
}
javascript
    )
    expect(response[:test_results][0][:result]).to include('getaddrinfo EAI_AGAIN')
    expect(response[:status]).to eq(:failed)
  end

  it 'prevents calls to node require' do
    response = bridge.run_tests!(test: 'describe("foo", () => it("bar", (done) => foo(http, done)))',
                                 extra: '',
                                 expectations: [],
                                 content: 'require("something");')
    expect(response[:status]).to eq :aborted
    expect(response[:result]).to eq 'You can not use require here'
  end

  it 'answers a valid hash when submission is ok' do
    response = bridge.run_tests!(test: 'describe("foo", () => it("bar", () => assert.equal(aVariable, 3)))',
                                 extra: '',
                                 content: 'var aVariable = 3',
                                 expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'foo bar', status: :passed, result: ''}],
                           status: :passed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end

  it 'answers a valid hash when submission is ok but has part of blacklisted words' do
    response = bridge.run_tests!(test: 'describe("foos", () => it("bar", () => assert.equal(aVariable, 3)))',
                                 extra: 'var flos = 75;',
                                 content: 'var aVariable = 3',
                                 expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'foos bar', status: :passed, result: ''}],
                           status: :passed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end

  xit 'answers a valid hash when submission is ok with warnings' do
    response = bridge.run_tests!(test: 'describe("foo", () => it("bar", () => assert.equal(x, 3)))',
                                 extra: '',
                                 content: 'var x = 3',
                                 expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'foo bar', status: :passed, result: ''}],
                           status: :passed_with_warnings,
                           feedback: '',
                           expectation_results: [{binding: 'x', inspection: 'HasTooShortIdentifiers', result: :failed}],
                           result: '')
  end

  it 'answers a valid hash when submission is not ok' do
    response = bridge.
        run_tests!(test: 'describe("foo", () => it("bar", () => assert.equal(aVariable, 3)))',
                   extra: '',
                   content: 'var aVariable = 2',
                   expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [
                               {title: 'foo bar', status: :failed, result: '2 == 3'}],
                           status: :failed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end

  xit 'answers a valid hash when submission timeouts' do
    response = bridge.
        run_tests!(test: 'describe("foo", () => it("bar", function (done) { this.timeout(7000); setTimeout(() => { assert.equal(x, 3); done() }, 7000) }))',
                   extra: '',
                   content: 'var x = 2',
                   expectations: [])

    expect(response).to eq(response_type: :unstructured,
                           test_results: [],
                           status: :aborted,
                           feedback: '',
                           expectation_results: [{binding: 'x', inspection: 'HasTooShortIdentifiers', result: :failed}],
                           result: 'Execution time limit of 6s exceeded. Is your program performing an infinite loop or recursion?')
  end


  it 'answers a valid hash when submission has compilation errors' do
    response = bridge.
        run_tests!(test: 'describe("foo", () => it("bar", () => assert.equal(x, 3)))',
                   extra: '',
                   content: 'var x = ).',
                   expectations: [])

    expect(response[:status]).to eq :errored
    expect(response[:response_type]).to eq(:unstructured)
    expect(response[:test_results]).to be_empty
    expect(response[:result]).to include('SyntaxError: Unexpected token \')\'')

  end

  it 'answers a valid hash when given a known locale' do
    response = bridge.run_tests!(test: 'describe("foo", () => it("bar", () => assert.equal(aVariable, 4)))',
                                 extra: '',
                                 content: 'var aVariable = 3',
                                 expectations: [],
                                 locale: 'pt')

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'foo bar', status: :failed, result: '3 == 4'}],
                           status: :failed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end


  it 'answers a valid hash when submission fails with `is not defined`' do
    response = bridge.run_tests!(
        test: %q{
          describe("average", () => {
            it("works with 3 elements", () => {
              assert.equal(average([1, 2, 3]), 3);
            });
            it("works with 2 elements", () => {
              assert.equal(average([1, 3]), 3);
            });
          });
        },
        extra: '',
        content: 'function average(list) {  return  sum(list) / list.length }',
        expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [
                             {result: "sum is not defined", status: :failed, title: "average works with 3 elements"},
                             {result: "sum is not defined", status: :failed, title: "average works with 2 elements"}],
                           status: :failed,
                           feedback: '* it looks like you are using `sum` but it is not defined. Perhaps you have misspelled it or you need to define it',
                           expectation_results: [],
                           result: '')
  end
end
