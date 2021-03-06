describe "appBuildJobs", ->

  $scope   = null
  $compile = null
  elem     = null
  job1     = null
  job2     = null

  beforeEach ->
    module("Vx")
    inject ['$rootScope', '$compile',
      (_$scope_, _$compile_) ->
        $scope   = _$scope_.$new()
        $compile = _$compile_
    ]

  beforeEach ->
    job1 = {
      matrix: {"rvm": "2.0.0", 'natural_number': "1"}
    }

    job2 = {
      matrix: {"rvm": "1.9.3", 'natural_number': "2"}
    }

  beforeEach ->
    $scope.jobs = []
    elem = angular.element('<div class="app-build-jobs" jobs="jobs">')
    $compile(elem)($scope)

  describe "with empty jobs", ->
    it "should have empty content", ->
      expect(elem.find("tbody").text()).toEqual "\n"

  describe "with jobs", ->
    beforeEach ->
      $scope.jobs.push job1
      $scope.jobs.push job2
      $scope.$digest()

    it "should display jobs", ->
      expect(elem.html()).toMatch 'rvm'
      expect(elem.html()).toMatch '2.0.0'
      expect(elem.html()).toMatch '1.9.3'

