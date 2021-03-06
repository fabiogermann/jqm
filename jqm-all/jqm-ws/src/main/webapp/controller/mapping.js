'use strict';

var jqmControllers = angular.module('jqmControllers');

jqmControllers
		.controller(
				'µQueueMappingListCtrl',
				function($scope, $http, µQueueMappingDto, µQueueDto, µNodeDto, jqmCellTemplateBoolean, jqmCellEditorTemplateBoolean, uiGridConstants, $interval) {
					$scope.mappings = null;
					$scope.queues = [];
					$scope.nodes = [];
					$scope.selected = [];
					$scope.bDbBusy = false;
					$scope.error = null;

					$scope.newmapping = function() {
						var t = new µQueueMappingDto({
							nodeId : $scope.nodes[0].id,
							queueId : $scope.queues[0].id,
							nbThread : 10,
							pollingInterval : 60000,
						});
						$scope.mappings.push(t);
						$scope.gridApi.selection.selectRow(t);
				        $interval(function() {
				            $scope.gridApi.cellNav.scrollToFocus(t, $scope.gridOptions.columnDefs[0]);
				        }, 0, 1);
					};

					$scope.save = function() {
						// Save and refresh the table - ID may have been
						// generated by the server.
						$scope.bDbBusy = true;
						µQueueMappingDto.saveAll({}, $scope.mappings, $scope.refresh);
					};

					$scope.refresh = function() {
						$scope.selected.length = 0;
						$scope.mappings = µQueueMappingDto.query();

						µQueueDto.query().$promise.then(function(data) {
							$scope.queues.length = 0;
							Array.prototype.push.apply($scope.queues, data);
						});
						µNodeDto.query().$promise.then(function(data) {
							$scope.nodes.length = 0;
							Array.prototype.push.apply($scope.nodes, data);
						});

						$scope.bDbBusy = false;
					};

					$scope.remove = function() {
						var q = null;
						for (var i = 0; i < $scope.selected.length; i++) {
							q = $scope.selected[i];
							if (q.id !== null && q.id !== undefined) {
								q.$remove({
									id : q.id
								});
							}
							$scope.mappings.splice($scope.mappings.indexOf(q), 1);
						}
						$scope.selected.length = 0;
					};

					$scope.filterOptions = {
						filterText : '',
					};

					$scope.gridOptions = {
						data : 'mappings',

						enableSelectAll : false,
						enableRowSelection : true,
						enableRowHeaderSelection : true,
						enableFullRowSelection : false,
						enableFooterTotalSelected : false,
						multiSelect : true,
						enableSelectionBatchEvent: false,
						noUnselect: false,

						onRegisterApi : function(gridApi) {
							$scope.gridApi = gridApi;
							gridApi.selection.on.rowSelectionChanged($scope, function(rows) {
								$scope.selected = gridApi.selection.getSelectedRows();
							});
							$scope.gridApi.grid.registerRowsProcessor(createGlobalFilter($scope, [ 'node.name', 'queue.name' ]), 200);
						},

						enableColumnMenus : false,
						enableCellEditOnFocus : true,
						virtualizationThreshold : 20,
						enableHorizontalScrollbar : 0,

						columnDefs : [
								{
									field : 'nodeId',
									displayName : 'Node',
									cellTemplate : '<div class="ui-grid-cell-contents"><span ng-cell-text>{{ (row.entity["nodeId"] | getByProperty:"id":grid.appScope.nodes).name }}</span></div>',
									editableCellTemplate : 'ui-grid/dropdownEditor',
									editDropdownValueLabel : 'name',
									editDropdownOptionsArray : $scope.nodes,
								},
								{
									field : 'queueId',
									displayName : 'Queue',
									cellTemplate : '<div class="ui-grid-cell-contents"><span ng-cell-text>{{ (row.entity["queueId"] | getByProperty:"id":grid.appScope.queues).name }}</span></div>',
									editableCellTemplate : 'ui-grid/dropdownEditor',
									editDropdownValueLabel : 'name',
									editDropdownOptionsArray : $scope.queues,
								},
								{
									field : 'pollingInterval',
									displayName : 'Polling Interval (ms)',
									editableCellTemplate: '<div><form name="inputForm"><input type="number" min="100" max="10000000" ng-required="true" ng-class="\'colt\' + col.uid" ui-grid-editor ng-model="MODEL_COL_FIELD" /></form></div>',
								},
								{
									field : 'nbThread',
									displayName : 'Max concurrent running instances',
									editableCellTemplate: '<div><form name="inputForm"><input type="number" min="1" max="1000" ng-required="true" ng-class="\'colt\' + col.uid" ui-grid-editor ng-model="MODEL_COL_FIELD" /></form></div>',
								}, {
									field : 'enabled',
									displayName : 'Enabled',
									cellTemplate : jqmCellTemplateBoolean,
									editableCellTemplate : jqmCellEditorTemplateBoolean,
									width : '*',
								}, ]
					};

					$scope.$watch('mappings', function(newMappings) {
						var q = null;
						var nodes = {};
						for (var i = 0; i < newMappings.length; i++) {
							q = newMappings[i];
							if (!(q.nodeId in nodes)) {
								nodes[q.nodeId] = [];
							}
							var nodeMappings = nodes[q.nodeId];

							if (nodeMappings.indexOf(q.queueId) != -1) {
								$scope.error = {
									"userReadableMessage" : "Cannot have two mappings for the same queue inside a single node",
									"errorCode" : null,
								};
								return;
							}
							nodeMappings.push(q.queueId);
						}

						// If here, no duplicates
						$scope.error = null;
					}, true);

					$scope.refresh();
				});

jqmControllers.filter('getByProperty', function() {
	return function(propertyValue, propertyName, collection) {
		var i = 0, len = collection.length;
		for (; i < len; i++) {
			if (collection[i][propertyName] === +propertyValue) {
				return collection[i];
			}
		}
		return null;
	};
});