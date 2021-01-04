class JavascriptMetadataHook < Mumukit::Hook
  def metadata
    {language: {
        name: 'javascript',
        icon: {type: 'devicon', name: 'javascript'},
        version: '12',
        extension: 'js',
        ace_mode: 'javascript'
    },
     test_framework: {
         name: 'mocha',
         version: '2.5.3',
         test_extension: '.js',
         template: <<js
describe("{{ test_template_group_description }}", function() {
  it("{{ test_template_sample_description }}", function() {
    assert(true)
  })
})
js
     }}
  end
end
