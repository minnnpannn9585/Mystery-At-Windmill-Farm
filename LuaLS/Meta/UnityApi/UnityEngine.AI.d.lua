--- ⚠️ 本文件由工具自动生成，请勿手动修改
--- Generated automatically. DO NOT EDIT MANUALLY.

---@meta _
---@diagnostic disable

--- UnityEngine.AI
UnityEngine.AI = {}

--- Status of path.
---@enum UnityEngine.AI.NavMeshPathStatus
local NavMeshPathStatus_Enum = {
    --- The path terminates at the destination.
    PathComplete = 0,
    --- The path cannot reach the destination.
    PathPartial = 1,
    --- The path is invalid.
    PathInvalid = 2,
}
UnityEngine.AI.NavMeshPathStatus = NavMeshPathStatus_Enum

--- Level of obstacle avoidance.
---@enum UnityEngine.AI.ObstacleAvoidanceType
local ObstacleAvoidanceType_Enum = {
    --- Disable avoidance.
    NoObstacleAvoidance = 0,
    --- Enable simple avoidance. Low performance impact.
    LowQualityObstacleAvoidance = 1,
    --- Medium avoidance. Medium performance impact.
    MedQualityObstacleAvoidance = 2,
    --- Good avoidance. High performance impact.
    GoodQualityObstacleAvoidance = 3,
    --- Enable highest precision. Highest performance impact.
    HighQualityObstacleAvoidance = 4,
}
UnityEngine.AI.ObstacleAvoidanceType = ObstacleAvoidanceType_Enum

--- Shape of the obstacle.
---@enum UnityEngine.AI.NavMeshObstacleShape
local NavMeshObstacleShape_Enum = {
    --- Capsule shaped obstacle.
    Capsule = 0,
    --- Box shaped obstacle.
    Box = 1,
}
UnityEngine.AI.NavMeshObstacleShape = NavMeshObstacleShape_Enum

--- Link type specifier.
---@enum UnityEngine.AI.OffMeshLinkType
local OffMeshLinkType_Enum = {
    --- Manually specified type of link.
    LinkTypeManual = 0,
    --- Vertical drop.
    LinkTypeDropDown = 1,
    --- Horizontal jump.
    LinkTypeJumpAcross = 2,
}
UnityEngine.AI.OffMeshLinkType = OffMeshLinkType_Enum

--- Bitmask used for operating with debug data from the NavMesh build process.
---@enum UnityEngine.AI.NavMeshBuildDebugFlags
local NavMeshBuildDebugFlags_Enum = {
    --- No debug data from the NavMesh build process is taken into consideration.
    None = 0,
    --- The triangles of all the geometry that is used as a base for computing the new NavMesh.
    InputGeometry = 1,
    --- The voxels produced by rasterizing the source geometry into walkable and unwalkable areas.
    Voxels = 2,
    --- The segmentation of the traversable surfaces into smaller areas necessary for producing simple polygons.
    Regions = 4,
    --- The contours that follow precisely the edges of each surface region.
    RawContours = 8,
    --- Contours bounding each of the surface regions, described through fewer vertices and straighter edges compared to RawContours.
    SimplifiedContours = 16,
    --- Meshes of convex polygons constructed within the unified contours of adjacent regions.
    PolygonMeshes = 32,
    --- The triangulated meshes with height details that better approximate the source geometry.
    PolygonMeshesDetail = 64,
    --- All debug data from the NavMesh build process is taken into consideration.
    All = 127,
}
UnityEngine.AI.NavMeshBuildDebugFlags = NavMeshBuildDebugFlags_Enum

--- Used with NavMeshBuildSource to define the shape for building NavMesh.
---@enum UnityEngine.AI.NavMeshBuildSourceShape
local NavMeshBuildSourceShape_Enum = {
    --- Describes a Mesh source for use with NavMeshBuildSource. Mesh sources must be positioned within 100,000 units of the origin and must not exceed 100,000 units in any axis-aligned dimension.
    Mesh = 0,
    --- Describes a TerrainData source for use with NavMeshBuildSource.
    Terrain = 1,
    --- Describes a box primitive for use with NavMeshBuildSource.
    Box = 2,
    --- Describes a sphere primitive for use with NavMeshBuildSource.
    Sphere = 3,
    --- Describes a capsule primitive for use with NavMeshBuildSource.
    Capsule = 4,
    --- Describes a ModifierBox source for use with NavMeshBuildSource.
    ModifierBox = 5,
}
UnityEngine.AI.NavMeshBuildSourceShape = NavMeshBuildSourceShape_Enum

--- Used for specifying the type of geometry to collect. Used with NavMeshBuilder.CollectSources.
---@enum UnityEngine.AI.NavMeshCollectGeometry
local NavMeshCollectGeometry_Enum = {
    --- Collect meshes form the rendered geometry.
    RenderMeshes = 0,
    --- Collect geometry from the 3D physics collision representation.
    PhysicsColliders = 1,
}
UnityEngine.AI.NavMeshCollectGeometry = NavMeshCollectGeometry_Enum

--- A path as calculated by the navigation system.
---@class UnityEngine.AI.NavMeshPath
--- Corner points of the path. (Read Only)
---@field corners UnityEngine.Vector3[]
--- Status of the path. (Read Only)
---@field status UnityEngine.AI.NavMeshPathStatus
local NavMeshPath_Impl = {}

--- Calculate the corners for the path.
---@param results UnityEngine.Vector3[] Array to store path corners.
---@return integer ret The number of corners along the path - including start and end points.
function NavMeshPath_Impl:GetCornersNonAlloc(results) end

--- Erase all corner points from path.
function NavMeshPath_Impl:ClearCorners() end

---@class Static.UnityEngine.AI.NavMeshPath
---@overload fun(): UnityEngine.AI.NavMeshPath (Constructor)
local NavMeshPath_Static = {}


---@type Static.UnityEngine.AI.NavMeshPath
UnityEngine.AI.NavMeshPath = NavMeshPath_Static

--------------------------------------------------------------------------------

---@class UnityEngine.AI.NavMeshBuilder
local NavMeshBuilder_Impl = {}

---@class Static.UnityEngine.AI.NavMeshBuilder
local NavMeshBuilder_Static = {}

---@param includedWorldBounds UnityEngine.Bounds 
---@param includedLayerMask integer 
---@param geometry UnityEngine.AI.NavMeshCollectGeometry 
---@param defaultArea integer 
---@param markups System.Collections.Generic.List 
---@param results System.Collections.Generic.List 
function NavMeshBuilder_Static.CollectSources(includedWorldBounds, includedLayerMask, geometry, defaultArea, markups, results) end

---@param root UnityEngine.Transform 
---@param includedLayerMask integer 
---@param geometry UnityEngine.AI.NavMeshCollectGeometry 
---@param defaultArea integer 
---@param markups System.Collections.Generic.List 
---@param results System.Collections.Generic.List 
function NavMeshBuilder_Static.CollectSources(root, includedLayerMask, geometry, defaultArea, markups, results) end

---@param buildSettings UnityEngine.AI.NavMeshBuildSettings 
---@param sources System.Collections.Generic.List 
---@param localBounds UnityEngine.Bounds 
---@param position UnityEngine.Vector3 
---@param rotation UnityEngine.Quaternion 
---@return UnityEngine.AI.NavMeshData ret 
function NavMeshBuilder_Static.BuildNavMeshData(buildSettings, sources, localBounds, position, rotation) end

---@param data UnityEngine.AI.NavMeshData 
---@param buildSettings UnityEngine.AI.NavMeshBuildSettings 
---@param sources System.Collections.Generic.List 
---@param localBounds UnityEngine.Bounds 
---@return boolean ret 
function NavMeshBuilder_Static.UpdateNavMeshData(data, buildSettings, sources, localBounds) end

---@param data UnityEngine.AI.NavMeshData 
---@param buildSettings UnityEngine.AI.NavMeshBuildSettings 
---@param sources System.Collections.Generic.List 
---@param localBounds UnityEngine.Bounds 
---@return UnityEngine.AsyncOperation ret 
function NavMeshBuilder_Static.UpdateNavMeshDataAsync(data, buildSettings, sources, localBounds) end

---@param data UnityEngine.AI.NavMeshData 
function NavMeshBuilder_Static.Cancel(data) end


---@type Static.UnityEngine.AI.NavMeshBuilder
UnityEngine.AI.NavMeshBuilder = NavMeshBuilder_Static

--------------------------------------------------------------------------------

--- Navigation mesh agent.
---@class UnityEngine.AI.NavMeshAgent : UnityEngine.Behaviour
--- Gets or attempts to set the destination of the agent in world-space units.
---@field destination UnityEngine.Vector3
--- Stop within this distance from the target position.
---@field stoppingDistance number
--- Access the current velocity of the NavMeshAgent component, or set a velocity to control the agent manually.
---@field velocity UnityEngine.Vector3
--- Gets or sets the simulation position of the navmesh agent.
---@field nextPosition UnityEngine.Vector3
--- Get the current steering target along the path. (Read Only)
---@field steeringTarget UnityEngine.Vector3
--- The desired velocity of the agent including any potential contribution from avoidance. (Read Only)
---@field desiredVelocity UnityEngine.Vector3
--- The distance between the agent's position and the destination on the current path. (Read Only)
---@field remainingDistance number
--- The relative vertical displacement of the owning GameObject.
---@field baseOffset number
--- Is the agent currently positioned on an OffMeshLink? (Read Only)
---@field isOnOffMeshLink boolean
--- The current OffMeshLinkData.
---@field currentOffMeshLinkData UnityEngine.AI.OffMeshLinkData
--- The next OffMeshLinkData on the current path.
---@field nextOffMeshLinkData UnityEngine.AI.OffMeshLinkData
--- Should the agent move across OffMeshLinks automatically?
---@field autoTraverseOffMeshLink boolean
--- Should the agent brake automatically to avoid overshooting the destination point?
---@field autoBraking boolean
--- Should the agent attempt to acquire a new path if the existing path becomes invalid?
---@field autoRepath boolean
--- Does the agent currently have a path? (Read Only)
---@field hasPath boolean
--- Is a path in the process of being computed but not yet ready? (Read Only)
---@field pathPending boolean
--- Is the current path stale. (Read Only)
---@field isPathStale boolean
--- The status of the current path (complete, partial or invalid).
---@field pathStatus UnityEngine.AI.NavMeshPathStatus
---@field pathEndPosition UnityEngine.Vector3
--- This property holds the stop or resume condition of the NavMesh agent.
---@field isStopped boolean
--- Property to get and set the current path.
---@field path UnityEngine.AI.NavMeshPath
--- Returns the owning object of the NavMesh the agent is currently placed on (Read Only).
---@field navMeshOwner UnityEngine.Object
--- The type ID for the agent.
---@field agentTypeID integer
--- Specifies which NavMesh layers are passable (bitfield). Changing walkableMask will make the path stale (see isPathStale).
---@field walkableMask integer
--- Specifies which NavMesh areas are passable. Changing areaMask will make the path stale (see isPathStale).
---@field areaMask integer
--- Maximum movement speed when following a path.
---@field speed number
--- Maximum turning speed in (deg/s) while following a path.
---@field angularSpeed number
--- The maximum acceleration of an agent as it follows a path, given in units / sec^2.
---@field acceleration number
--- Gets or sets whether the transform position is synchronized with the simulated agent position. The default value is true.
---@field updatePosition boolean
--- Should the agent update the transform orientation?
---@field updateRotation boolean
--- Allows you to specify whether the agent should be aligned to the up-axis of the NavMesh or link that it is placed on.
---@field updateUpAxis boolean
--- The avoidance radius for the agent.
---@field radius number
--- The height of the agent for purposes of passing under obstacles, etc.
---@field height number
--- The level of quality of avoidance.
---@field obstacleAvoidanceType UnityEngine.AI.ObstacleAvoidanceType
--- The avoidance priority level.
---@field avoidancePriority integer
--- Is the agent currently bound to the navmesh? (Read Only)
---@field isOnNavMesh boolean
local NavMeshAgent_Impl = {}

--- Sets or updates the destination thus triggering the calculation for a new path.
---@param target UnityEngine.Vector3 The target point to navigate to.
---@return boolean ret True if the destination was requested successfully, otherwise false.
function NavMeshAgent_Impl:SetDestination(target) end

--- Enables or disables the current off-mesh link.
---@param activated boolean Is the link activated?
function NavMeshAgent_Impl:ActivateCurrentOffMeshLink(activated) end

--- Completes the movement on the current OffMeshLink.
function NavMeshAgent_Impl:CompleteOffMeshLink() end

--- Warps agent to the provided position.
---@param newPosition UnityEngine.Vector3 New position to warp the agent to.
---@return boolean ret True if agent is successfully warped, otherwise false.
function NavMeshAgent_Impl:Warp(newPosition) end

--- Apply relative movement to current position.
---@param offset UnityEngine.Vector3 The relative movement vector.
function NavMeshAgent_Impl:Move(offset) end

--- Stop movement of this agent along its current path.
function NavMeshAgent_Impl:Stop() end

---@param stopUpdates boolean 
function NavMeshAgent_Impl:Stop(stopUpdates) end

--- Resumes the movement along the current path after a pause.
function NavMeshAgent_Impl:Resume() end

--- Clears the current path.
function NavMeshAgent_Impl:ResetPath() end

--- Assign a new path to this agent.
---@param path UnityEngine.AI.NavMeshPath New path to follow.
---@return boolean ret True if the path is succesfully assigned.
function NavMeshAgent_Impl:SetPath(path) end

--- Locate the closest NavMesh edge.
---@return boolean ret True if a nearest edge is found.
---@return UnityEngine.AI.NavMeshHit hit (Out) Holds the properties of the resulting location.
function NavMeshAgent_Impl:FindClosestEdge() end

--- Trace a straight path towards a target postion in the NavMesh without moving the agent.
---@param targetPosition UnityEngine.Vector3 The desired end position of movement.
---@return boolean ret True if there is an obstacle between the agent and the target position, otherwise false.
---@return UnityEngine.AI.NavMeshHit hit (Out) Properties of the obstacle detected by the ray (if any).
function NavMeshAgent_Impl:Raycast(targetPosition) end

--- Calculate a path to a specified point and store the resulting path.
---@param targetPosition UnityEngine.Vector3 The final position of the path requested.
---@param path UnityEngine.AI.NavMeshPath The resulting path.
---@return boolean ret True if a path is found.
function NavMeshAgent_Impl:CalculatePath(targetPosition, path) end

--- Sample a position along the current path.
---@param areaMask integer A bitfield mask specifying which NavMesh areas can be passed when tracing the path.
---@param maxDistance number Terminate scanning the path at this distance.
---@return boolean ret True if terminated before reaching the position at maxDistance, false otherwise.
---@return UnityEngine.AI.NavMeshHit hit (Out) Holds the properties of the resulting location.
function NavMeshAgent_Impl:SamplePathPosition(areaMask, maxDistance) end

--- Sets the cost for traversing over geometry of the layer type.
---@param layer integer Layer index.
---@param cost number New cost for the specified layer.
function NavMeshAgent_Impl:SetLayerCost(layer, cost) end

--- Gets the cost for crossing ground of a particular type.
---@param layer integer Layer index.
---@return number ret Current cost of specified layer.
function NavMeshAgent_Impl:GetLayerCost(layer) end

--- Sets the cost for traversing over areas of the area type.
---@param areaIndex integer Area cost.
---@param areaCost number New cost for the specified area index.
function NavMeshAgent_Impl:SetAreaCost(areaIndex, areaCost) end

--- Gets the cost for path calculation when crossing area of a particular type.
---@param areaIndex integer Area Index.
---@return number ret Current cost for specified area index.
function NavMeshAgent_Impl:GetAreaCost(areaIndex) end

---@class Static.UnityEngine.AI.NavMeshAgent
---@overload fun(): UnityEngine.AI.NavMeshAgent (Constructor)
local NavMeshAgent_Static = {}


---@type Static.UnityEngine.AI.NavMeshAgent
UnityEngine.AI.NavMeshAgent = NavMeshAgent_Static

--------------------------------------------------------------------------------

--- An obstacle for NavMeshAgents to avoid.
---@class UnityEngine.AI.NavMeshObstacle : UnityEngine.Behaviour
--- Height of the obstacle's cylinder shape.
---@field height number
--- Radius of the obstacle's capsule shape.
---@field radius number
--- Velocity at which the obstacle moves around the NavMesh.
---@field velocity UnityEngine.Vector3
--- Should this obstacle make a cut-out in the navmesh.
---@field carving boolean
--- Should this obstacle be carved when it is constantly moving?
---@field carveOnlyStationary boolean
--- Threshold distance for updating a moving carved hole (when carving is enabled).
---@field carvingMoveThreshold number
--- Time to wait until obstacle is treated as stationary (when carving and carveOnlyStationary are enabled).
---@field carvingTimeToStationary number
--- The shape of the obstacle.
---@field shape UnityEngine.AI.NavMeshObstacleShape
--- The center of the obstacle, measured in the object's local space.
---@field center UnityEngine.Vector3
--- The size of the obstacle, measured in the object's local space.
---@field size UnityEngine.Vector3
local NavMeshObstacle_Impl = {}

---@class Static.UnityEngine.AI.NavMeshObstacle
---@overload fun(): UnityEngine.AI.NavMeshObstacle (Constructor)
local NavMeshObstacle_Static = {}


---@type Static.UnityEngine.AI.NavMeshObstacle
UnityEngine.AI.NavMeshObstacle = NavMeshObstacle_Static

--------------------------------------------------------------------------------

--- State of OffMeshLink.
---@class UnityEngine.AI.OffMeshLinkData
--- Is link valid (Read Only).
---@field valid boolean
--- Is link active (Read Only).
---@field activated boolean
--- Link type specifier (Read Only).
---@field linkType UnityEngine.AI.OffMeshLinkType
--- Link start world position (Read Only).
---@field startPos UnityEngine.Vector3
--- Link end world position (Read Only).
---@field endPos UnityEngine.Vector3
--- The OffMeshLink if the link type is a manually placed Offmeshlink (Read Only).
---@field offMeshLink UnityEngine.AI.OffMeshLink
local OffMeshLinkData_Impl = {}

---@class Static.UnityEngine.AI.OffMeshLinkData
---@overload fun(): UnityEngine.AI.OffMeshLinkData (Constructor)
local OffMeshLinkData_Static = {}


---@type Static.UnityEngine.AI.OffMeshLinkData
UnityEngine.AI.OffMeshLinkData = OffMeshLinkData_Static

--------------------------------------------------------------------------------

--- Link allowing movement outside the planar navigation mesh.
---@class UnityEngine.AI.OffMeshLink : UnityEngine.Behaviour
--- Is link active.
---@field activated boolean
--- Is link occupied. (Read Only)
---@field occupied boolean
--- Modify pathfinding cost for the link.
---@field costOverride number
--- Can link be traversed in both directions.
---@field biDirectional boolean
--- NavMeshLayer for this OffMeshLink component.
---@field navMeshLayer integer
--- NavMesh area index for this OffMeshLink component.
---@field area integer
--- Automatically update endpoints.
---@field autoUpdatePositions boolean
--- The transform representing link start position.
---@field startTransform UnityEngine.Transform
--- The transform representing link end position.
---@field endTransform UnityEngine.Transform
local OffMeshLink_Impl = {}

--- Explicitly update the link endpoints.
function OffMeshLink_Impl:UpdatePositions() end

---@class Static.UnityEngine.AI.OffMeshLink
---@overload fun(): UnityEngine.AI.OffMeshLink (Constructor)
local OffMeshLink_Static = {}


---@type Static.UnityEngine.AI.OffMeshLink
UnityEngine.AI.OffMeshLink = OffMeshLink_Static

--------------------------------------------------------------------------------

--- Result information for NavMesh queries.
---@class UnityEngine.AI.NavMeshHit
--- Position of hit.
---@field position UnityEngine.Vector3
--- Normal at the point of hit.
---@field normal UnityEngine.Vector3
--- Distance to the point of hit.
---@field distance number
--- Mask specifying NavMesh area at point of hit.
---@field mask integer
--- Flag set when hit.
---@field hit boolean
local NavMeshHit_Impl = {}

---@class Static.UnityEngine.AI.NavMeshHit
---@overload fun(): UnityEngine.AI.NavMeshHit (Constructor)
local NavMeshHit_Static = {}


---@type Static.UnityEngine.AI.NavMeshHit
UnityEngine.AI.NavMeshHit = NavMeshHit_Static

--------------------------------------------------------------------------------

--- Contains data describing a triangulation of a navmesh.
---@class UnityEngine.AI.NavMeshTriangulation
--- NavMeshLayer values for the navmesh triangulation.
---@field layers integer[]
--- Vertices for the navmesh triangulation.
---@field vertices UnityEngine.Vector3[]
--- Triangle indices for the navmesh triangulation.
---@field indices integer[]
--- NavMesh area indices for the navmesh triangulation.
---@field areas integer[]
local NavMeshTriangulation_Impl = {}

---@class Static.UnityEngine.AI.NavMeshTriangulation
---@overload fun(): UnityEngine.AI.NavMeshTriangulation (Constructor)
local NavMeshTriangulation_Static = {}


---@type Static.UnityEngine.AI.NavMeshTriangulation
UnityEngine.AI.NavMeshTriangulation = NavMeshTriangulation_Static

--------------------------------------------------------------------------------

--- Contains and represents NavMesh data.
---@class UnityEngine.AI.NavMeshData : UnityEngine.Object
--- Returns the bounding volume of the input geometry used to build this NavMesh (Read Only).
---@field sourceBounds UnityEngine.Bounds
--- Gets or sets the world space position of the NavMesh data.
---@field position UnityEngine.Vector3
--- Gets or sets the orientation of the NavMesh data.
---@field rotation UnityEngine.Quaternion
local NavMeshData_Impl = {}

---@class Static.UnityEngine.AI.NavMeshData
---@overload fun(): UnityEngine.AI.NavMeshData (Constructor)
---@overload fun(agentTypeID:integer): UnityEngine.AI.NavMeshData (Constructor)
local NavMeshData_Static = {}


---@type Static.UnityEngine.AI.NavMeshData
UnityEngine.AI.NavMeshData = NavMeshData_Static

--------------------------------------------------------------------------------

--- The instance is returned when adding NavMesh data.
---@class UnityEngine.AI.NavMeshDataInstance
--- True if the NavMesh data is added to the navigation system - otherwise false (Read Only).
---@field valid boolean
--- Get or set the owning Object.
---@field owner UnityEngine.Object
local NavMeshDataInstance_Impl = {}

--- Removes this instance from the NavMesh system.
function NavMeshDataInstance_Impl:Remove() end

---@class Static.UnityEngine.AI.NavMeshDataInstance
---@overload fun(): UnityEngine.AI.NavMeshDataInstance (Constructor)
local NavMeshDataInstance_Static = {}


---@type Static.UnityEngine.AI.NavMeshDataInstance
UnityEngine.AI.NavMeshDataInstance = NavMeshDataInstance_Static

--------------------------------------------------------------------------------

--- Used for runtime manipulation of links connecting polygons of the NavMesh.
---@class UnityEngine.AI.NavMeshLinkData
--- Start position of the link.
---@field startPosition UnityEngine.Vector3
--- End position of the link.
---@field endPosition UnityEngine.Vector3
--- If positive, overrides the pathfinder cost to traverse the link.
---@field costModifier number
--- If true, the link can be traversed in both directions, otherwise only from start to end position.
---@field bidirectional boolean
--- If positive, the link will be rectangle aligned along the line from start to end.
---@field width number
--- Area type of the link.
---@field area integer
--- Specifies which agent type this link is available for.
---@field agentTypeID integer
local NavMeshLinkData_Impl = {}

---@class Static.UnityEngine.AI.NavMeshLinkData
---@overload fun(): UnityEngine.AI.NavMeshLinkData (Constructor)
local NavMeshLinkData_Static = {}


---@type Static.UnityEngine.AI.NavMeshLinkData
UnityEngine.AI.NavMeshLinkData = NavMeshLinkData_Static

--------------------------------------------------------------------------------

--- An instance representing a link available for pathfinding.
---@class UnityEngine.AI.NavMeshLinkInstance
--- True if the NavMesh link is added to the navigation system - otherwise false (Read Only).
---@field valid boolean
--- Get or set the owning Object.
---@field owner UnityEngine.Object
local NavMeshLinkInstance_Impl = {}

--- Removes this instance from the game.
function NavMeshLinkInstance_Impl:Remove() end

---@class Static.UnityEngine.AI.NavMeshLinkInstance
---@overload fun(): UnityEngine.AI.NavMeshLinkInstance (Constructor)
local NavMeshLinkInstance_Static = {}


---@type Static.UnityEngine.AI.NavMeshLinkInstance
UnityEngine.AI.NavMeshLinkInstance = NavMeshLinkInstance_Static

--------------------------------------------------------------------------------

--- Specifies which agent type and areas to consider when searching the NavMesh.
---@class UnityEngine.AI.NavMeshQueryFilter
--- A bitmask representing the traversable area types.
---@field areaMask integer
--- The agent type ID, specifying which navigation meshes to consider for the query functions.
---@field agentTypeID integer
local NavMeshQueryFilter_Impl = {}

--- Returns the area cost multiplier for the given area type for this filter.
---@param areaIndex integer Index to retreive the cost for.
---@return number ret The cost multiplier for the supplied area index.
function NavMeshQueryFilter_Impl:GetAreaCost(areaIndex) end

--- Sets the pathfinding cost multiplier for this filter for a given area type.
---@param areaIndex integer The area index to set the cost for.
---@param cost number The cost for the supplied area index.
function NavMeshQueryFilter_Impl:SetAreaCost(areaIndex, cost) end

---@class Static.UnityEngine.AI.NavMeshQueryFilter
---@overload fun(): UnityEngine.AI.NavMeshQueryFilter (Constructor)
local NavMeshQueryFilter_Static = {}


---@type Static.UnityEngine.AI.NavMeshQueryFilter
UnityEngine.AI.NavMeshQueryFilter = NavMeshQueryFilter_Static

--------------------------------------------------------------------------------

--- Singleton class to access the baked NavMesh.
---@class UnityEngine.AI.NavMesh
local NavMesh_Impl = {}

---@class Static.UnityEngine.AI.NavMesh
--- Describes how far in the future the agents predict collisions for avoidance.
---@field avoidancePredictionTime number
--- The maximum number of nodes processed for each frame during the asynchronous pathfinding process.
---@field pathfindingIterationsPerFrame integer
--- Area mask constant that includes all NavMesh areas.
---@field AllAreas integer
--- Set a function to be called before the NavMesh is updated during the frame update execution.
---@field onPreUpdate fun()
local NavMesh_Static = {}

--- Trace a line between two points on the NavMesh.
---@param sourcePosition UnityEngine.Vector3 The origin of the ray.
---@param targetPosition UnityEngine.Vector3 The end of the ray.
---@param areaMask integer A bitfield mask specifying which NavMesh areas can be passed when tracing the ray.
---@return boolean ret True if the ray is terminated before reaching target position. Otherwise returns false.
---@return UnityEngine.AI.NavMeshHit hit (Out) Holds the properties of the ray cast resulting location.
function NavMesh_Static.Raycast(sourcePosition, targetPosition, areaMask) end

--- Calculate a path between two points and store the resulting path.
---@param sourcePosition UnityEngine.Vector3 The initial position of the path requested.
---@param targetPosition UnityEngine.Vector3 The final position of the path requested.
---@param areaMask integer A bitfield mask specifying which NavMesh areas can be passed when calculating a path.
---@param path UnityEngine.AI.NavMeshPath The resulting path.
---@return boolean ret True if either a complete or partial path is found. False otherwise.
function NavMesh_Static.CalculatePath(sourcePosition, targetPosition, areaMask, path) end

--- Locate the closest NavMesh edge from a point on the NavMesh.
---@param sourcePosition UnityEngine.Vector3 The origin of the distance query.
---@param areaMask integer A bitfield mask specifying which NavMesh areas can be passed when finding the nearest edge.
---@return boolean ret True if the nearest edge is found.
---@return UnityEngine.AI.NavMeshHit hit (Out) Holds the properties of the resulting location.
function NavMesh_Static.FindClosestEdge(sourcePosition, areaMask) end

--- Finds the nearest point based on the NavMesh within a specified range.
---@param sourcePosition UnityEngine.Vector3 The origin of the sample query.
---@param maxDistance number Sample within this distance from sourcePosition.
---@param areaMask integer A mask that specifies the NavMesh areas allowed when finding the nearest point.
---@return boolean ret True if the nearest point is found.
---@return UnityEngine.AI.NavMeshHit hit (Out) Holds the properties of the resulting location. The value of hit.normal is never computed. It is always (0,0,0).
function NavMesh_Static.SamplePosition(sourcePosition, maxDistance, areaMask) end

--- Sets the cost for traversing over geometry of the layer type on all agents.
---@param layer integer 
---@param cost number 
function NavMesh_Static.SetLayerCost(layer, cost) end

--- Gets the cost for traversing over geometry of the layer type on all agents.
---@param layer integer 
---@return number ret 
function NavMesh_Static.GetLayerCost(layer) end

--- Returns the layer index for a named layer.
---@param layerName string 
---@return integer ret 
function NavMesh_Static.GetNavMeshLayerFromName(layerName) end

--- Sets the cost for finding path over geometry of the area type on all agents.
---@param areaIndex integer Index of the area to set.
---@param cost number New cost.
function NavMesh_Static.SetAreaCost(areaIndex, cost) end

--- Gets the cost for path finding over geometry of the area type.
---@param areaIndex integer Index of the area to get.
---@return number ret 
function NavMesh_Static.GetAreaCost(areaIndex) end

--- Returns the area index for a named NavMesh area type.
---@param areaName string Name of the area to look up.
---@return integer ret Index if the specified are, or -1 if no area found.
function NavMesh_Static.GetAreaFromName(areaName) end

--- Calculates triangulation of the current navmesh.
---@return UnityEngine.AI.NavMeshTriangulation ret 
function NavMesh_Static.CalculateTriangulation() end

---@return UnityEngine.Vector3[] vertices (Out) 
---@return integer[] indices (Out) 
function NavMesh_Static.Triangulate() end

function NavMesh_Static.AddOffMeshLinks() end

function NavMesh_Static.RestoreNavMesh() end

--- Adds the specified NavMeshData to the game.
---@param navMeshData UnityEngine.AI.NavMeshData Contains the data for the navmesh.
---@return UnityEngine.AI.NavMeshDataInstance ret Representing the added navmesh.
function NavMesh_Static.AddNavMeshData(navMeshData) end

--- Adds the specified NavMeshData to the game.
---@param navMeshData UnityEngine.AI.NavMeshData Contains the data for the navmesh.
---@param position UnityEngine.Vector3 Translate the navmesh to this position.
---@param rotation UnityEngine.Quaternion Rotate the navmesh to this orientation.
---@return UnityEngine.AI.NavMeshDataInstance ret Representing the added navmesh.
function NavMesh_Static.AddNavMeshData(navMeshData, position, rotation) end

--- Removes the specified NavMeshDataInstance from the game, making it unavailable for agents and queries.
---@param handle UnityEngine.AI.NavMeshDataInstance The instance of a NavMesh to remove.
function NavMesh_Static.RemoveNavMeshData(handle) end

--- Adds a link to the NavMesh. The link is described by the NavMeshLinkData struct.
---@param link UnityEngine.AI.NavMeshLinkData Describing the properties of the link.
---@return UnityEngine.AI.NavMeshLinkInstance ret Representing the added link.
function NavMesh_Static.AddLink(link) end

--- Adds a link to the NavMesh. The link is described by the NavMeshLinkData struct.
---@param link UnityEngine.AI.NavMeshLinkData Describing the properties of the link.
---@param position UnityEngine.Vector3 Translate the link to this position.
---@param rotation UnityEngine.Quaternion Rotate the link to this orientation.
---@return UnityEngine.AI.NavMeshLinkInstance ret Representing the added link.
function NavMesh_Static.AddLink(link, position, rotation) end

--- Removes a link from the NavMesh.
---@param handle UnityEngine.AI.NavMeshLinkInstance The instance of a link to remove.
function NavMesh_Static.RemoveLink(handle) end

--- Samples the position nearest the sourcePosition on any NavMesh built for the agent type specified by the filter.
---@param sourcePosition UnityEngine.Vector3 The origin of the sample query.
---@param maxDistance number Sample within this distance from sourcePosition.
---@param filter UnityEngine.AI.NavMeshQueryFilter A filter specifying which NavMesh areas are allowed when finding the nearest point.
---@return boolean ret True if the nearest point is found.
---@return UnityEngine.AI.NavMeshHit hit (Out) Holds the properties of the resulting location. The value of hit.normal is never computed. It is always (0,0,0).
function NavMesh_Static.SamplePosition(sourcePosition, maxDistance, filter) end

--- Locate the closest NavMesh edge from a point on the NavMesh, subject to the constraints of the filter argument.
---@param sourcePosition UnityEngine.Vector3 The origin of the distance query.
---@param filter UnityEngine.AI.NavMeshQueryFilter A filter specifying which NavMesh areas can be passed when finding the nearest edge.
---@return boolean ret True if the nearest edge is found.
---@return UnityEngine.AI.NavMeshHit hit (Out) Holds the properties of the resulting location.
function NavMesh_Static.FindClosestEdge(sourcePosition, filter) end

--- Traces a line between two positions on the NavMesh, subject to the constraints defined by the filter argument.
---@param sourcePosition UnityEngine.Vector3 The origin of the ray.
---@param targetPosition UnityEngine.Vector3 The end of the ray.
---@param filter UnityEngine.AI.NavMeshQueryFilter A filter specifying which NavMesh areas can be passed when tracing the ray.
---@return boolean ret True if the ray is terminated before reaching target position. Otherwise returns false.
---@return UnityEngine.AI.NavMeshHit hit (Out) Holds the properties of the ray cast resulting location.
function NavMesh_Static.Raycast(sourcePosition, targetPosition, filter) end

--- Calculates a path between two positions mapped to the NavMesh, subject to the constraints and costs defined by the filter argument.
---@param sourcePosition UnityEngine.Vector3 The initial position of the path requested.
---@param targetPosition UnityEngine.Vector3 The final position of the path requested.
---@param filter UnityEngine.AI.NavMeshQueryFilter A filter specifying the cost of NavMesh areas that can be passed when calculating a path.
---@param path UnityEngine.AI.NavMeshPath The resulting path.
---@return boolean ret True if a either a complete or partial path is found and false otherwise.
function NavMesh_Static.CalculatePath(sourcePosition, targetPosition, filter, path) end

--- Creates and returns a new entry of NavMesh build settings available for runtime NavMesh building.
---@return UnityEngine.AI.NavMeshBuildSettings ret The created settings.
function NavMesh_Static.CreateSettings() end

--- Removes the build settings matching the agent type ID.
---@param agentTypeID integer The ID of the entry to remove.
function NavMesh_Static.RemoveSettings(agentTypeID) end

--- Returns an existing entry of NavMesh build settings.
---@param agentTypeID integer The ID to look for.
---@return UnityEngine.AI.NavMeshBuildSettings ret The settings found.
function NavMesh_Static.GetSettingsByID(agentTypeID) end

--- Returns the number of registered NavMesh build settings.
---@return integer ret The number of registered entries.
function NavMesh_Static.GetSettingsCount() end

--- Returns an existing entry of NavMesh build settings by its ordered index.
---@param index integer The index to retrieve from.
---@return UnityEngine.AI.NavMeshBuildSettings ret The found settings.
function NavMesh_Static.GetSettingsByIndex(index) end

--- Returns the name associated with the NavMesh build settings matching the provided agent type ID.
---@param agentTypeID integer The ID to look for.
---@return string ret The name associated with the ID found.
function NavMesh_Static.GetSettingsNameFromID(agentTypeID) end

--- Removes all NavMesh surfaces and links from the game.
function NavMesh_Static.RemoveAllNavMeshData() end


---@type Static.UnityEngine.AI.NavMesh
UnityEngine.AI.NavMesh = NavMesh_Static

--------------------------------------------------------------------------------

--- The input to the NavMesh builder is a list of NavMesh build sources.
---@class UnityEngine.AI.NavMeshBuildSource
--- Describes the local to world transformation matrix of the build source. That is, position and orientation and scale of the shape.
---@field transform UnityEngine.Matrix4x4
--- Describes the dimensions of the shape.
---@field size UnityEngine.Vector3
--- The type of the shape this source describes. See Also: NavMeshBuildSourceShape.
---@field shape UnityEngine.AI.NavMeshBuildSourceShape
--- Describes the area type of the NavMesh surface for this object.
---@field area integer
--- Describes the object referenced for Mesh and Terrain types of input sources.
---@field sourceObject UnityEngine.Object
--- Points to the owning component - if available, otherwise null.
---@field component UnityEngine.Component
local NavMeshBuildSource_Impl = {}

---@class Static.UnityEngine.AI.NavMeshBuildSource
---@overload fun(): UnityEngine.AI.NavMeshBuildSource (Constructor)
local NavMeshBuildSource_Static = {}


---@type Static.UnityEngine.AI.NavMeshBuildSource
UnityEngine.AI.NavMeshBuildSource = NavMeshBuildSource_Static

--------------------------------------------------------------------------------

--- The NavMesh build markup allows you to control how certain objects are treated during the NavMesh build process, specifically when collecting sources for building.
---@class UnityEngine.AI.NavMeshBuildMarkup
--- Use this to specify whether the area type of the GameObject and its children should be overridden by the area type specified in this struct.
---@field overrideArea boolean
--- The area type to use when override area is enabled.
---@field area integer
--- Use this to specify whether the GameObject and its children should be ignored.
---@field ignoreFromBuild boolean
--- Use this to specify which GameObject (including the GameObject’s children) the markup should be applied to.
---@field root UnityEngine.Transform
local NavMeshBuildMarkup_Impl = {}

---@class Static.UnityEngine.AI.NavMeshBuildMarkup
---@overload fun(): UnityEngine.AI.NavMeshBuildMarkup (Constructor)
local NavMeshBuildMarkup_Static = {}


---@type Static.UnityEngine.AI.NavMeshBuildMarkup
UnityEngine.AI.NavMeshBuildMarkup = NavMeshBuildMarkup_Static

--------------------------------------------------------------------------------

--- The NavMeshBuildSettings struct allows you to specify a collection of settings which describe the dimensions and limitations of a particular agent type.
---@class UnityEngine.AI.NavMeshBuildSettings
--- The agent type ID the NavMesh will be baked for.
---@field agentTypeID integer
--- The radius of the agent for baking in world units.
---@field agentRadius number
--- The height of the agent for baking in world units.
---@field agentHeight number
--- The maximum slope angle which is walkable (angle in degrees).
---@field agentSlope number
--- The maximum vertical step size an agent can take.
---@field agentClimb number
--- The approximate minimum area of individual NavMesh regions.
---@field minRegionArea number
--- Enables overriding the default voxel size. See Also: voxelSize.
---@field overrideVoxelSize boolean
--- Sets the voxel size in world length units.
---@field voxelSize number
--- Enables overriding the default tile size. See Also: tileSize.
---@field overrideTileSize boolean
--- Sets the tile size in voxel units.
---@field tileSize integer
--- The maximum number of worker threads that the build process can utilize when building a NavMesh with these settings.
---@field maxJobWorkers integer
---@field preserveTilesOutsideBounds boolean
--- Options for collecting debug data during the build process.
---@field debug UnityEngine.AI.NavMeshBuildDebugSettings
local NavMeshBuildSettings_Impl = {}

--- Validates the properties of NavMeshBuildSettings.
---@param buildBounds UnityEngine.Bounds Describes the volume to build NavMesh for.
---@return string[] ret The list of violated constraints.
function NavMeshBuildSettings_Impl:ValidationReport(buildBounds) end

---@class Static.UnityEngine.AI.NavMeshBuildSettings
---@overload fun(): UnityEngine.AI.NavMeshBuildSettings (Constructor)
local NavMeshBuildSettings_Static = {}


---@type Static.UnityEngine.AI.NavMeshBuildSettings
UnityEngine.AI.NavMeshBuildSettings = NavMeshBuildSettings_Static

--------------------------------------------------------------------------------

--- Specify which of the temporary data generated while building the NavMesh should be retained in memory after the process has completed.
---@class UnityEngine.AI.NavMeshBuildDebugSettings
--- Specify which types of debug data to collect when building the NavMesh.
---@field flags UnityEngine.AI.NavMeshBuildDebugFlags
local NavMeshBuildDebugSettings_Impl = {}

---@class Static.UnityEngine.AI.NavMeshBuildDebugSettings
---@overload fun(): UnityEngine.AI.NavMeshBuildDebugSettings (Constructor)
local NavMeshBuildDebugSettings_Static = {}


---@type Static.UnityEngine.AI.NavMeshBuildDebugSettings
UnityEngine.AI.NavMeshBuildDebugSettings = NavMeshBuildDebugSettings_Static

--------------------------------------------------------------------------------

