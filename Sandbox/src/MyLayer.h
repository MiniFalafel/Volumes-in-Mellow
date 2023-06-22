#pragma once

#include "Mellow/Base/Layer.h"
#include "Mellow/Events/MouseEvent.h"
#include "Mellow/Events/KeyEvent.h"

#include "Mellow/Controllers/CameraController.h"

#include "Mellow/Renderer/Renderer.h"
#include "Mellow/Renderer/Shader.h"

// Mesh/Scene stuff
#include "Mellow/Renderer/Geometry/Mesh.h"
#include "Mellow/Renderer/Texture.h"

struct CameraToggleCallbackParams
{
	bool CurrentToggleState;
};

using namespace Mellow;

class VolumeCube
{
	// mesh data
	Ref<Mesh> m_QuadMesh;
	// shader params
	glm::vec3 m_Min, m_Max;
	float m_Density;

public:
	VolumeCube(glm::vec3 min, glm::vec3 max, float density);

	// Getters
	Ref<Mesh> GetMesh() { return m_QuadMesh; }
	glm::vec3 GetMin() { return m_Min; }
	glm::vec3 GetMax() { return m_Max; }
	float GetDensity() { return m_Density; }

	// Setters
	void SetDensity(float density) { m_Density = density; }
	void SetMin(glm::vec3 min) { m_Min = min; }
	void SetMax(glm::vec3 max) { m_Max = max; }

private:
};

class MyLayer : public Layer {

	bool OnMouseMovement(MouseMovedEvent& e);
	bool OnKeyPress(KeyPressedEvent& e);

public:
	MyLayer();

	void OnAttach() override;
	void OnDetach() override;
	void OnEvent(Event& e) override;
	void OnUpdate(Timestep ts) override;
	void OnImGuiRender() override;

private:

	CameraController m_CameraController;
	CameraToggleCallbackParams m_CamToggleParams = { false, };

	// Shader
	ShaderLibrary m_ShaderLib;

	// Ground Plane
	Ref<Mesh> m_FloorPlaneMesh;
	Ref<Texture2D> m_FloorTextureAlbedo;
	Ref<Texture2D> m_FloorTextureRoughness;
	Ref<Texture2D> m_FloorTextureNormal;
	float m_FloorTextureScale = 3.0f;
	Transform3D m_FloorPlaneT;

	// Volume Cube
	Ref<VolumeCube> m_Volume;

	// Lighting
	struct PointLight
	{
		glm::vec3 Position;
		glm::vec3 Color;
		float Power;
	};

	PointLight m_PointLight = {
		glm::vec3(2.4f, 0.41f, 1.2f),
		glm::vec3(1.0f),
		9.0f,
	};

};