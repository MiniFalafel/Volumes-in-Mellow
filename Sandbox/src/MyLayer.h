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
	float m_FloorTextureScale = 1.0f;
	Transform3D m_FloorPlaneT;

	// Lighting
	struct PointLight
	{
		glm::vec3 Position;
		glm::vec3 Color;
		float Power;
	};

	PointLight m_PointLight = {
		glm::vec3(2.4f, 3.2f, 1.2f),
		glm::vec3(1.0f),
		1.0f,
	};

};