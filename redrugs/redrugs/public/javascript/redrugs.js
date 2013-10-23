var redrugsApp = angular.module('redrugsApp', []);

redrugsApp.controller('ReDrugSCtrl', function ReDrugSCtrl($scope, $http) {
    $scope.elements = {
        nodes:[],
        edges:[]
    };
    $scope.nodeMap = {};
    $scope.edges = [];
    $scope.resources = {};
    $scope.searchTerms = "";
    $scope.searchTermURIs = {};
    $scope.getNode = function(uri) {
        var node = $scope.nodeMap[uri];
        if (!node) {
            node = $scope.nodeMap[uri] = {
                group: "nodes",
                data: {
                    id: uri
                }
            };
            $scope.elements.nodes.push(node);
        }
        return node;
    }
    $("#searchBox").typeahead({
        minLength: 3,
        items: 10,
        updater: function(selection) {
            console.log(selection);
            $scope.searchTerms = selection;
            return selection;
        },
        source: function(query, process) {
            console.log(query);
            $http({method:'GET',url:"/api/typeahead?q="+encodeURIComponent(query)}).success(function(data) {
                var keywords = data.keywords.map(function(d) {
                    $scope.searchTermURIs[$.trim(d[0])] = d[1];
                    return $.trim(d[0]);
                });
                process(keywords);
            });
        } 
    });
    $scope.addToGraph = function(query) {
        console.log(query);
        query = query.split(",").map(function(d) {
            return encodeURIComponent($scope.searchTermURIs[$.trim(d)])
        }).join(",")
        console.log(query);
        $http({method:'GET',url:"/api/addToGraph?uris="+query})
            .success($scope.appendToGraph);
    }
    $scope.appendToGraph = function(result) {
        console.log(result);
        $scope.edges = $scope.edges.concat(result.edges);
        result.edges.forEach(function(row) {
            if (!(row.probability > 0.4)) return;
            var source = $scope.getNode(row.participant);
            source.data.label = row.participantLabel;
            var target = $scope.getNode(row.target);
            target.data.label = row.targetLabel;
            var edge = {
                group: "edges",
                data: $().extend({}, row, {
                    source:source.data.id,
                    target:target.data.id
                })
            };
            $scope.elements.edges.push(edge);
        });
        var elements = $scope.elements.nodes.concat($scope.elements.edges);
        console.log(elements);
        $('#results').cytoscape({
              layout: {
                  name: 'breadthfirst',
                  fit: false, // whether to fit the viewport to the graph
                  ready: undefined, // callback on layoutready
                  stop: undefined, // callback on layoutstop
                  directed: true, // whether the tree is directed downwards (or edges can point in any direction if false)
                  padding: 30, // padding on fit
                  circle: true, // put depths in concentric circles if true, put depths top down if false
                  roots: undefined // the roots of the trees
              },
              style: cytoscape.stylesheet()
                .selector('node')
                .css({
                    'content': 'data(label)',
                    'text-valign': 'center',
                    'color': 'white',
                    'text-outline-width': 2,
                    'text-outline-color': '#888'
                })
                .selector('edge')
                .css({
                    'target-arrow-shape': 'triangle',
                    'opacity':0.5,
                    'width':"data(likelihood+0.1)"
                })
                .selector(':selected')
                .css({
                    'background-color': 'black',
                    'line-color': 'black',
                    'target-arrow-color': 'black',
                    'source-arrow-color': 'black',
                    'opacity':1,
                })
                .selector('.faded')
                .css({
                    'opacity': 0.25,
                    'text-opacity': 0
                }),
            elements: elements ,
            ready: function(){
                $scope.cy = cy = this;
                // giddy up...
                console.log(cy.elements());
                cy.elements().unselectify();
    
                cy.on('tap', 'node', function(e){
                    var node = e.cyTarget; 
                    var neighborhood = node.neighborhood().add(node);
                    
                    cy.elements().addClass('faded');
                    neighborhood.removeClass('faded');
                });
                
                cy.on('tap', function(e){
                    if( e.cyTarget === cy ){
                        cy.elements().removeClass('faded');
                    }
                });
                layoutOptions = {
                    name: 'breadthfirst',
                    fit: true, // whether to fit the viewport to the graph
                    ready: undefined, // callback on layoutready
                    stop: undefined, // callback on layoutstop
                    directed: true, // whether the tree is directed downwards (or edges can point in any direction if false)
                    padding: 30, // padding on fit
                    circle: false, // put depths in concentric circles if true, put depths top down if false
                    roots: undefined // the roots of the trees
                };
                
                //cy.layout( layoutOptions );
                console.log($scope.cy);
            }
        });
        //$scope.updateDisplay();
    }
    $scope.result = $("#result");
    //$scope.svg = d3.select("#graph");
    //$scope.force = d3.layout.force();
    //.size([w, h]);
    //function updateSize() {
    //     width = $scope.result.width();
    //     height = $scope.result.height();
    //     $scope.svg.attr("width",width)
    //         .attr("height",height);
    //     //force.stop()
    //     $scope.force.size([width, height]);
    //     //    .start();
    // }
    // $(window).resize(updateSize);
    $scope.updateDisplay = function() {
        // $scope.force.stop()
        //     .charge(-1000)
        //     .size([$scope.result.width(), $scope.result.height()])
        //     .linkStrength(1)
        //     .linkDistance(30)
        //     .gravity(0.05)
        //     .nodes($scope.nodes)
        //     .links($scope.edges);
        // $scope.edgeSVG = $scope.makeEdgeSVG($scope.edges, $scope.svg);
        // $scope.nodeSVG = $scope.makeNodeSVG($scope.nodes, $scope.svg);
        // $scope.force.start();
    }

    $scope.makeEdgeSVG = function(edges, svg) {
        var result = svg.selectAll("line.edge")
            .data(edges).enter()
            .append("line")
            .attr("class","edge")
            .attr("stroke","black");
        return svg.selectAll("line.edge");
    }
    $scope.makeNodeSVG = function(nodes, svg) {
        var result = svg.selectAll("g.node")
            .data(nodes)
            .enter()
            .append("g")
            .attr("class","node")
        result.append("circle")
            .attr("r",20)
            .attr("stroke","black")
            .attr("fill","steelblue")
        result.append("text")
            .style("text-anchor","middle")
            .style("dominant-baseline","central")
            .text(function(d) {return d.label});
        return svg.selectAll("g.node");
    }
    // $scope.force.on("tick", function() {
    //     $scope.edgeSVG
    //         .attr("x1",function(d) {
    //             return d.source.x;
    //         })
    //         .attr("y1",function(d) {
    //             return d.source.y;
    //         })
    //         .attr("x2",function(d) {
    //             return d.target.x;
    //         })
    //         .attr("y2",function(d) {
    //             return d.target.y;
    //         })
    //     $scope.nodeSVG
    //         .attr("transform", function(d) {
    //             return "translate("+d.x+","+d.y+")";
    //         })
    // })
})