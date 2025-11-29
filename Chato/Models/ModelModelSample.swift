import Fakery
import Foundation
import os

extension ModelModel {
//  static var samples: [ModelModel] = {
//    let faker = Faker()
//    var samples = [ModelModel]()
//    for _ in 0 ..< 100 {
//      let id = UUID().uuidString
//      let name = faker.company.name()
//      let info = faker.lorem.sentence()
//      let contextLength = faker.number.randomInt(min: 1000, max: 1000000)
//      let model = ModelModel(id: id, name: name)
//      model.info = info
//      model.contextLength = contextLength
//      samples.append(model)
//    }
//    return samples
//  }()
  static var samples: [ModelModel] = {
    do {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      let resp = try decoder.decode(ModelResponse.self, from: str.data(using: .utf8)!)
      return resp.data.compactMap { m in
        ModelModel(modelId: m.id, name: m.name)
      }
    } catch {
      AppLogger.logError(.from(
        error: error,
        operation: "Load model data",
        component: "ModelModelSample",
        userMessage: nil
      ))
      return []
    }
  }()
}

private let str = """
{
  "data": [
    {
      "id": "google/gemini-pro-1.5-exp",
      "name": "Google: Gemini Pro 1.5 Experimental",
      "created": 1722470400,
      "context_length": 1000000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Gemini",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0",
        "completion": "0",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 1000000,
        "max_completion_tokens": 8192,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "meta-llama/llama-3.2-11b-vision-instruct:free",
      "name": "Meta: Llama 3.2 11B Vision Instruct (free)",
      "created": 1727222400,
      "context_length": 131072,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Llama3",
        "instruct_type": "llama3"
      },
      "pricing": {
        "prompt": "0",
        "completion": "0",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 8192,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "google/gemini-flash-1.5-exp",
      "name": "Google: Gemini Flash 1.5 Experimental",
      "created": 1724803200,
      "context_length": 1000000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Gemini",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0",
        "completion": "0",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 1000000,
        "max_completion_tokens": 8192,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "google/gemini-flash-1.5-8b-exp",
      "name": "Google: Gemini Flash 1.5 8B Experimental",
      "created": 1724803200,
      "context_length": 1000000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Gemini",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0",
        "completion": "0",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 1000000,
        "max_completion_tokens": 8192,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "microsoft/phi-3-medium-128k-instruct:free",
      "name": "Microsoft: Phi-3 Medium 128K Instruct (free)",
      "created": 1716508800,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Other",
        "instruct_type": "phi3"
      },
      "pricing": {
        "prompt": "0",
        "completion": "0",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 8192,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "microsoft/phi-3-mini-128k-instruct:free",
      "name": "Microsoft: Phi-3 Mini 128K Instruct (free)",
      "created": 1716681600,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Other",
        "instruct_type": "phi3"
      },
      "pricing": {
        "prompt": "0",
        "completion": "0",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 8192,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "google/gemini-2.0-flash-thinking-exp:free",
      "name": "Google: Gemini 2.0 Flash Thinking Experimental (free)",
      "created": 1734650026,
      "context_length": 40000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Gemini",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0",
        "completion": "0",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 40000,
        "max_completion_tokens": 8000,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "google/gemini-2.0-flash-exp:free",
      "name": "Google: Gemini Flash 2.0 Experimental (free)",
      "created": 1733937523,
      "context_length": 1048576,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Gemini",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0",
        "completion": "0",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 1048576,
        "max_completion_tokens": 8192,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "meta-llama/llama-3.2-1b-instruct",
      "name": "Meta: Llama 3.2 1B Instruct",
      "created": 1727222400,
      "context_length": 131072,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Llama3",
        "instruct_type": "llama3"
      },
      "pricing": {
        "prompt": "0.00000001",
        "completion": "0.00000002",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 131072,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "meta-llama/llama-3.2-3b-instruct",
      "name": "Meta: Llama 3.2 3B Instruct",
      "created": 1727222400,
      "context_length": 131072,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Llama3",
        "instruct_type": "llama3"
      },
      "pricing": {
        "prompt": "0.000000018",
        "completion": "0.00000003",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 131072,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "meta-llama/llama-3.1-8b-instruct",
      "name": "Meta: Llama 3.1 8B Instruct",
      "created": 1721692800,
      "context_length": 131072,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Llama3",
        "instruct_type": "llama3"
      },
      "pricing": {
        "prompt": "0.00000002",
        "completion": "0.00000005",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 131072,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/mistral-7b-instruct",
      "name": "Mistral: Mistral 7B Instruct",
      "created": 1716768000,
      "context_length": 32768,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": "mistral"
      },
      "pricing": {
        "prompt": "0.00000003",
        "completion": "0.000000055",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 32768,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/mistral-7b-instruct-v0.3",
      "name": "Mistral: Mistral 7B Instruct v0.3",
      "created": 1716768000,
      "context_length": 32768,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": "mistral"
      },
      "pricing": {
        "prompt": "0.00000003",
        "completion": "0.000000055",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 32768,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "meta-llama/llama-3-8b-instruct",
      "name": "Meta: Llama 3 8B Instruct",
      "created": 1713398400,
      "context_length": 8192,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Llama3",
        "instruct_type": "llama3"
      },
      "pricing": {
        "prompt": "0.00000003",
        "completion": "0.00000006",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 8192,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "amazon/nova-micro-v1",
      "name": "Amazon: Nova Micro 1.0",
      "created": 1733437237,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Nova",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000000035",
        "completion": "0.00000014",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 5120,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "google/gemini-flash-1.5-8b",
      "name": "Google: Gemini Flash 1.5 8B",
      "created": 1727913600,
      "context_length": 1000000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Gemini",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000000375",
        "completion": "0.00000015",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 1000000,
        "max_completion_tokens": 8192,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/ministral-3b",
      "name": "Mistral: Ministral 3B",
      "created": 1729123200,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00000004",
        "completion": "0.00000004",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "meta-llama/llama-3.2-11b-vision-instruct",
      "name": "Meta: Llama 3.2 11B Vision Instruct",
      "created": 1727222400,
      "context_length": 131072,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Llama3",
        "instruct_type": "llama3"
      },
      "pricing": {
        "prompt": "0.000000055",
        "completion": "0.000000055",
        "image": "0.00007948",
        "request": "0"
      },
      "top_provider": {
        "context_length": 131072,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "amazon/nova-lite-v1",
      "name": "Amazon: Nova Lite 1.0",
      "created": 1733437363,
      "context_length": 300000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Nova",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00000006",
        "completion": "0.00000024",
        "image": "0.00009",
        "request": "0"
      },
      "top_provider": {
        "context_length": 300000,
        "max_completion_tokens": 5120,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "google/gemini-flash-1.5",
      "name": "Google: Gemini Flash 1.5",
      "created": 1715644800,
      "context_length": 1000000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Gemini",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000000075",
        "completion": "0.0000003",
        "image": "0.00004",
        "request": "0"
      },
      "top_provider": {
        "context_length": 1000000,
        "max_completion_tokens": 8192,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/ministral-8b",
      "name": "Mistral: Ministral 8B",
      "created": 1729123200,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000001",
        "completion": "0.0000001",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "microsoft/phi-3-mini-128k-instruct",
      "name": "Microsoft: Phi-3 Mini 128K Instruct",
      "created": 1716681600,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Other",
        "instruct_type": "phi3"
      },
      "pricing": {
        "prompt": "0.0000001",
        "completion": "0.0000001",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "microsoft/phi-3.5-mini-128k-instruct",
      "name": "Microsoft: Phi-3.5 Mini 128K Instruct",
      "created": 1724198400,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Other",
        "instruct_type": "phi3"
      },
      "pricing": {
        "prompt": "0.0000001",
        "completion": "0.0000001",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "meta-llama/llama-3.1-70b-instruct",
      "name": "Meta: Llama 3.1 70B Instruct",
      "created": 1721692800,
      "context_length": 131072,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Llama3",
        "instruct_type": "llama3"
      },
      "pricing": {
        "prompt": "0.00000013",
        "completion": "0.0000004",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 131072,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "deepseek/deepseek-chat",
      "name": "DeepSeek V2.5",
      "created": 1715644800,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Other",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00000014",
        "completion": "0.00000028",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 65536,
        "max_completion_tokens": 8192,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "cohere/command-r-08-2024",
      "name": "Cohere: Command R (08-2024)",
      "created": 1724976000,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Cohere",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000001425",
        "completion": "0.00000057",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 4000,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/mistral-nemo",
      "name": "Mistral: Mistral Nemo",
      "created": 1721347200,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": "mistral"
      },
      "pricing": {
        "prompt": "0.00000015",
        "completion": "0.00000015",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/pixtral-12b",
      "name": "Mistral: Pixtral 12B",
      "created": 1725926400,
      "context_length": 4096,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Mistral",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00000015",
        "completion": "0.00000015",
        "image": "0.0002168",
        "request": "0"
      },
      "top_provider": {
        "context_length": 4096,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-4o-mini",
      "name": "OpenAI: GPT-4o-mini",
      "created": 1721260800,
      "context_length": 128000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00000015",
        "completion": "0.0000006",
        "image": "0.007225",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 16384,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-4o-mini-2024-07-18",
      "name": "OpenAI: GPT-4o-mini (2024-07-18)",
      "created": 1721260800,
      "context_length": 128000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00000015",
        "completion": "0.0000006",
        "image": "0.007225",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 16384,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/mistral-7b-instruct-v0.1",
      "name": "Mistral: Mistral 7B Instruct v0.1",
      "created": 1695859200,
      "context_length": 4096,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": "mistral"
      },
      "pricing": {
        "prompt": "0.00000018",
        "completion": "0.00000018",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 4096,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "ai21/jamba-1-5-mini",
      "name": "AI21: Jamba 1.5 Mini",
      "created": 1724371200,
      "context_length": 256000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Other",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000002",
        "completion": "0.0000004",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 256000,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/mistral-small",
      "name": "Mistral Small",
      "created": 1704844800,
      "context_length": 32000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000002",
        "completion": "0.0000006",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 32000,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "qwen/qwen-2.5-72b-instruct",
      "name": "Qwen2.5 72B Instruct",
      "created": 1726704000,
      "context_length": 131072,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Qwen",
        "instruct_type": "chatml"
      },
      "pricing": {
        "prompt": "0.00000023",
        "completion": "0.0000004",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 32000,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "nvidia/llama-3.1-nemotron-70b-instruct",
      "name": "NVIDIA: Llama 3.1 Nemotron 70B Instruct",
      "created": 1728950400,
      "context_length": 131072,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Llama3",
        "instruct_type": "llama3"
      },
      "pricing": {
        "prompt": "0.00000023",
        "completion": "0.0000004",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 131072,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "meta-llama/llama-3-70b-instruct",
      "name": "Meta: Llama 3 70B Instruct",
      "created": 1713398400,
      "context_length": 8192,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Llama3",
        "instruct_type": "llama3"
      },
      "pricing": {
        "prompt": "0.00000023",
        "completion": "0.0000004",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 8192,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/mixtral-8x7b-instruct",
      "name": "Mistral: Mixtral 8x7B Instruct",
      "created": 1702166400,
      "context_length": 32768,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": "mistral"
      },
      "pricing": {
        "prompt": "0.00000024",
        "completion": "0.00000024",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 32768,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/mistral-tiny",
      "name": "Mistral Tiny",
      "created": 1704844800,
      "context_length": 32000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00000025",
        "completion": "0.00000025",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 32000,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/codestral-mamba",
      "name": "Mistral: Codestral Mamba",
      "created": 1721347200,
      "context_length": 256000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00000025",
        "completion": "0.00000025",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 256000,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "anthropic/claude-3-haiku:beta",
      "name": "Anthropic: Claude 3 Haiku (self-moderated)",
      "created": 1710288000,
      "context_length": 200000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Claude",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00000025",
        "completion": "0.00000125",
        "image": "0.0004",
        "request": "0"
      },
      "top_provider": {
        "context_length": 200000,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "anthropic/claude-3-haiku",
      "name": "Anthropic: Claude 3 Haiku",
      "created": 1710288000,
      "context_length": 200000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Claude",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00000025",
        "completion": "0.00000125",
        "image": "0.0004",
        "request": "0"
      },
      "top_provider": {
        "context_length": 200000,
        "max_completion_tokens": 4096,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "nousresearch/hermes-3-llama-3.1-70b",
      "name": "Nous: Hermes 3 70B Instruct",
      "created": 1723939200,
      "context_length": 131072,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Llama3",
        "instruct_type": "chatml"
      },
      "pricing": {
        "prompt": "0.0000004",
        "completion": "0.0000004",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 12288,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "cohere/command-r-03-2024",
      "name": "Cohere: Command R (03-2024)",
      "created": 1709341200,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Cohere",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000000475",
        "completion": "0.000001425",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 4000,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "cohere/command-r",
      "name": "Cohere: Command R",
      "created": 1710374400,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Cohere",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000000475",
        "completion": "0.000001425",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 4000,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-3.5-turbo-0125",
      "name": "OpenAI: GPT-3.5 Turbo 16k",
      "created": 1685232000,
      "context_length": 16385,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000005",
        "completion": "0.0000015",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 16385,
        "max_completion_tokens": 4096,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "google/gemini-pro",
      "name": "Google: Gemini Pro 1.0",
      "created": 1702425600,
      "context_length": 32760,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Gemini",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000005",
        "completion": "0.0000015",
        "image": "0.0025",
        "request": "0"
      },
      "top_provider": {
        "context_length": 32760,
        "max_completion_tokens": 8192,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-3.5-turbo",
      "name": "OpenAI: GPT-3.5 Turbo",
      "created": 1685232000,
      "context_length": 16385,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000005",
        "completion": "0.0000015",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 16385,
        "max_completion_tokens": 4096,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/mixtral-8x7b-instruct:nitro",
      "name": "Mistral: Mixtral 8x7B Instruct (nitro)",
      "created": 1702166400,
      "context_length": 32768,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": "mistral"
      },
      "pricing": {
        "prompt": "0.00000054",
        "completion": "0.00000054",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 32768,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "amazon/nova-pro-v1",
      "name": "Amazon: Nova Pro 1.0",
      "created": 1733436303,
      "context_length": 300000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Nova",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000008",
        "completion": "0.0000032",
        "image": "0.0012",
        "request": "0"
      },
      "top_provider": {
        "context_length": 300000,
        "max_completion_tokens": 5120,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "anthropic/claude-3.5-haiku:beta",
      "name": "Anthropic: Claude 3.5 Haiku (self-moderated)",
      "created": 1730678400,
      "context_length": 200000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Claude",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000008",
        "completion": "0.000004",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 200000,
        "max_completion_tokens": 8192,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "anthropic/claude-3.5-haiku",
      "name": "Anthropic: Claude 3.5 Haiku",
      "created": 1730678400,
      "context_length": 200000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Claude",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000008",
        "completion": "0.000004",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 200000,
        "max_completion_tokens": 8192,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "anthropic/claude-3.5-haiku-20241022:beta",
      "name": "Anthropic: Claude 3.5 Haiku (2024-10-22) (self-moderated)",
      "created": 1730678400,
      "context_length": 200000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Claude",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000008",
        "completion": "0.000004",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 200000,
        "max_completion_tokens": 8192,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "anthropic/claude-3.5-haiku-20241022",
      "name": "Anthropic: Claude 3.5 Haiku (2024-10-22)",
      "created": 1730678400,
      "context_length": 200000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Claude",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000008",
        "completion": "0.000004",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 200000,
        "max_completion_tokens": 8192,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "meta-llama/llama-3.1-405b-instruct",
      "name": "Meta: Llama 3.1 405B Instruct",
      "created": 1721692800,
      "context_length": 131072,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Llama3",
        "instruct_type": "llama3"
      },
      "pricing": {
        "prompt": "0.0000009",
        "completion": "0.0000009",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 32000,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "microsoft/phi-3-medium-128k-instruct",
      "name": "Microsoft: Phi-3 Medium 128K Instruct",
      "created": 1716508800,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Other",
        "instruct_type": "phi3"
      },
      "pricing": {
        "prompt": "0.000001",
        "completion": "0.000001",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-3.5-turbo-1106",
      "name": "OpenAI: GPT-3.5 Turbo 16k (older v1106)",
      "created": 1699228800,
      "context_length": 16385,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000001",
        "completion": "0.000002",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 16385,
        "max_completion_tokens": 4096,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-3.5-turbo-0613",
      "name": "OpenAI: GPT-3.5 Turbo (older v0613)",
      "created": 1706140800,
      "context_length": 4095,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000001",
        "completion": "0.000002",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 4095,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "meta-llama/llama-3.2-90b-vision-instruct",
      "name": "Meta: Llama 3.2 90B Vision Instruct",
      "created": 1727222400,
      "context_length": 131072,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Llama3",
        "instruct_type": "llama3"
      },
      "pricing": {
        "prompt": "0.00000108",
        "completion": "0.00000108",
        "image": "0.0015606",
        "request": "0"
      },
      "top_provider": {
        "context_length": 131072,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "google/gemini-pro-1.5",
      "name": "Google: Gemini Pro 1.5",
      "created": 1712620800,
      "context_length": 2000000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Gemini",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00000125",
        "completion": "0.000005",
        "image": "0.0006575",
        "request": "0"
      },
      "top_provider": {
        "context_length": 2000000,
        "max_completion_tokens": 8192,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/mixtral-8x22b-instruct",
      "name": "Mistral: Mixtral 8x22B Instruct",
      "created": 1713312000,
      "context_length": 65536,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": "mistral"
      },
      "pricing": {
        "prompt": "0.000002",
        "completion": "0.000006",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 65536,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/mistral-large",
      "name": "Mistral Large",
      "created": 1708905600,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000002",
        "completion": "0.000006",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/mistral-large-2407",
      "name": "Mistral Large 2407",
      "created": 1731978415,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000002",
        "completion": "0.000006",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/mistral-large-2411",
      "name": "Mistral Large 2411",
      "created": 1731978685,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000002",
        "completion": "0.000006",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/pixtral-large-2411",
      "name": "Mistral: Pixtral Large 2411",
      "created": 1731977388,
      "context_length": 128000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Mistral",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000002",
        "completion": "0.000006",
        "image": "0.002888",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "ai21/jamba-1-5-large",
      "name": "AI21: Jamba 1.5 Large",
      "created": 1724371200,
      "context_length": 256000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Other",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000002",
        "completion": "0.000008",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 256000,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "x-ai/grok-2-1212",
      "name": "xAI: Grok 2 1212",
      "created": 1734232814,
      "context_length": 131072,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Grok",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000002",
        "completion": "0.00001",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 131072,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "cohere/command-r-plus-08-2024",
      "name": "Cohere: Command R+ (08-2024)",
      "created": 1724976000,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Cohere",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000002375",
        "completion": "0.0000095",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 4000,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-4o",
      "name": "OpenAI: GPT-4o",
      "created": 1715558400,
      "context_length": 128000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000025",
        "completion": "0.00001",
        "image": "0.003613",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 16384,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-4o-2024-08-06",
      "name": "OpenAI: GPT-4o (2024-08-06)",
      "created": 1722902400,
      "context_length": 128000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000025",
        "completion": "0.00001",
        "image": "0.003613",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 16384,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-4o-2024-11-20",
      "name": "OpenAI: GPT-4o (2024-11-20)",
      "created": 1732127594,
      "context_length": 128000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.0000025",
        "completion": "0.00001",
        "image": "0.003613",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 16384,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "mistralai/mistral-medium",
      "name": "Mistral Medium",
      "created": 1704844800,
      "context_length": 32000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Mistral",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00000275",
        "completion": "0.0000081",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 32000,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "cohere/command-r-plus",
      "name": "Cohere: Command R+",
      "created": 1712188800,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Cohere",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00000285",
        "completion": "0.00001425",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 4000,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "cohere/command-r-plus-04-2024",
      "name": "Cohere: Command R+ (04-2024)",
      "created": 1712016000,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Cohere",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00000285",
        "completion": "0.00001425",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 4000,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-3.5-turbo-16k",
      "name": "OpenAI: GPT-3.5 Turbo 16k",
      "created": 1693180800,
      "context_length": 16385,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000003",
        "completion": "0.000004",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 16385,
        "max_completion_tokens": 4096,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "anthropic/claude-3.5-sonnet:beta",
      "name": "Anthropic: Claude 3.5 Sonnet (self-moderated)",
      "created": 1729555200,
      "context_length": 200000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Claude",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000003",
        "completion": "0.000015",
        "image": "0.0048",
        "request": "0"
      },
      "top_provider": {
        "context_length": 200000,
        "max_completion_tokens": 8192,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "anthropic/claude-3.5-sonnet",
      "name": "Anthropic: Claude 3.5 Sonnet",
      "created": 1729555200,
      "context_length": 200000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Claude",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000003",
        "completion": "0.000015",
        "image": "0.0048",
        "request": "0"
      },
      "top_provider": {
        "context_length": 200000,
        "max_completion_tokens": 8192,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "anthropic/claude-3-sonnet:beta",
      "name": "Anthropic: Claude 3 Sonnet (self-moderated)",
      "created": 1709596800,
      "context_length": 200000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Claude",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000003",
        "completion": "0.000015",
        "image": "0.0048",
        "request": "0"
      },
      "top_provider": {
        "context_length": 200000,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "anthropic/claude-3-sonnet",
      "name": "Anthropic: Claude 3 Sonnet",
      "created": 1709596800,
      "context_length": 200000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Claude",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000003",
        "completion": "0.000015",
        "image": "0.0048",
        "request": "0"
      },
      "top_provider": {
        "context_length": 200000,
        "max_completion_tokens": 4096,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "anthropic/claude-3.5-sonnet-20240620:beta",
      "name": "Anthropic: Claude 3.5 Sonnet (2024-06-20) (self-moderated)",
      "created": 1718841600,
      "context_length": 200000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Claude",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000003",
        "completion": "0.000015",
        "image": "0.0048",
        "request": "0"
      },
      "top_provider": {
        "context_length": 200000,
        "max_completion_tokens": 8192,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "anthropic/claude-3.5-sonnet-20240620",
      "name": "Anthropic: Claude 3.5 Sonnet (2024-06-20)",
      "created": 1718841600,
      "context_length": 200000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Claude",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000003",
        "completion": "0.000015",
        "image": "0.0048",
        "request": "0"
      },
      "top_provider": {
        "context_length": 200000,
        "max_completion_tokens": 8192,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-4o-2024-05-13",
      "name": "OpenAI: GPT-4o (2024-05-13)",
      "created": 1715558400,
      "context_length": 128000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000005",
        "completion": "0.000015",
        "image": "0.007225",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 4096,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "x-ai/grok-beta",
      "name": "xAI: Grok Beta",
      "created": 1729382400,
      "context_length": 131072,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "Grok",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000005",
        "completion": "0.000015",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 131072,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "x-ai/grok-vision-beta",
      "name": "xAI: Grok Vision Beta",
      "created": 1731976624,
      "context_length": 8192,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Grok",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000005",
        "completion": "0.000015",
        "image": "0.009",
        "request": "0"
      },
      "top_provider": {
        "context_length": 8192,
        "max_completion_tokens": null,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-4o:extended",
      "name": "OpenAI: GPT-4o (extended)",
      "created": 1715558400,
      "context_length": 128000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000006",
        "completion": "0.000018",
        "image": "0.007225",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 64000,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-4-turbo",
      "name": "OpenAI: GPT-4 Turbo",
      "created": 1712620800,
      "context_length": 128000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00001",
        "completion": "0.00003",
        "image": "0.01445",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 4096,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-4-1106-preview",
      "name": "OpenAI: GPT-4 Turbo (older v1106)",
      "created": 1699228800,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00001",
        "completion": "0.00003",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 4096,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-4-turbo-preview",
      "name": "OpenAI: GPT-4 Turbo Preview",
      "created": 1706140800,
      "context_length": 128000,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00001",
        "completion": "0.00003",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 128000,
        "max_completion_tokens": 4096,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "anthropic/claude-3-opus:beta",
      "name": "Anthropic: Claude 3 Opus (self-moderated)",
      "created": 1709596800,
      "context_length": 200000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Claude",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000015",
        "completion": "0.000075",
        "image": "0.024",
        "request": "0"
      },
      "top_provider": {
        "context_length": 200000,
        "max_completion_tokens": 4096,
        "is_moderated": false
      },
      "per_request_limits": null
    },
    {
      "id": "anthropic/claude-3-opus",
      "name": "Anthropic: Claude 3 Opus",
      "created": 1709596800,
      "context_length": 200000,
      "architecture": {
        "modality": "text+image->text",
        "tokenizer": "Claude",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.000015",
        "completion": "0.000075",
        "image": "0.024",
        "request": "0"
      },
      "top_provider": {
        "context_length": 200000,
        "max_completion_tokens": 4096,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-4",
      "name": "OpenAI: GPT-4",
      "created": 1685232000,
      "context_length": 8191,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00003",
        "completion": "0.00006",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 8191,
        "max_completion_tokens": 4096,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-4-0314",
      "name": "OpenAI: GPT-4 (older v0314)",
      "created": 1685232000,
      "context_length": 8191,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00003",
        "completion": "0.00006",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 8191,
        "max_completion_tokens": 4096,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-4-32k-0314",
      "name": "OpenAI: GPT-4 32k (older v0314)",
      "created": 1693180800,
      "context_length": 32767,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00006",
        "completion": "0.00012",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 32767,
        "max_completion_tokens": 4096,
        "is_moderated": true
      },
      "per_request_limits": null
    },
    {
      "id": "openai/gpt-4-32k",
      "name": "OpenAI: GPT-4 32k",
      "created": 1693180800,
      "context_length": 32767,
      "architecture": {
        "modality": "text->text",
        "tokenizer": "GPT",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00006",
        "completion": "0.00012",
        "image": "0",
        "request": "0"
      },
      "top_provider": {
        "context_length": 32767,
        "max_completion_tokens": 4096,
        "is_moderated": true
      },
      "per_request_limits": null
    }
  ]
}
"""
