from http import HTTPStatus
from typing import Any

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.error import Error
from ...types import UNSET, Response, Unset


def _get_kwargs(
    *,
    workspace: Unset | str = UNSET,
    access_token: Unset | str = UNSET,
) -> dict[str, Any]:
    params: dict[str, Any] = {}

    params["workspace"] = workspace

    params["access_token"] = access_token

    params = {k: v for k, v in params.items() if v is not UNSET and v is not None}

    _kwargs: dict[str, Any] = {
        "method": "get",
        "url": "/shipr/stream",
        "params": params,
    }

    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> Error | str | None:
    if response.status_code == 200:
        response_200 = response.text
        return response_200

    if response.status_code == 401:
        response_401 = Error.from_dict(response.json())

        return response_401

    if response.status_code == 403:
        response_403 = Error.from_dict(response.json())

        return response_403

    if response.status_code == 404:
        response_404 = Error.from_dict(response.json())

        return response_404

    if client.raise_on_unexpected_status:
        raise errors.UnexpectedStatus(response.status_code, response.content)
    else:
        return None


def _build_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> Response[Error | str]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    *,
    client: AuthenticatedClient,
    workspace: Unset | str = UNSET,
    access_token: Unset | str = UNSET,
) -> Response[Error | str]:
    """The workspace’s runs as they change state

     A wake channel, not a log: `run` events carry a run’s identity and state so the tree can show what
    is moving. Open the per-run stream for output.

    Args:
        workspace (Union[Unset, str]):
        access_token (Union[Unset, str]):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[Union[Error, str]]
    """

    kwargs = _get_kwargs(
        workspace=workspace,
        access_token=access_token,
    )

    response = client.get_httpx_client().request(
        **kwargs,
    )

    return _build_response(client=client, response=response)


def sync(
    *,
    client: AuthenticatedClient,
    workspace: Unset | str = UNSET,
    access_token: Unset | str = UNSET,
) -> Error | str | None:
    """The workspace’s runs as they change state

     A wake channel, not a log: `run` events carry a run’s identity and state so the tree can show what
    is moving. Open the per-run stream for output.

    Args:
        workspace (Union[Unset, str]):
        access_token (Union[Unset, str]):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Union[Error, str]
    """

    return sync_detailed(
        client=client,
        workspace=workspace,
        access_token=access_token,
    ).parsed


async def asyncio_detailed(
    *,
    client: AuthenticatedClient,
    workspace: Unset | str = UNSET,
    access_token: Unset | str = UNSET,
) -> Response[Error | str]:
    """The workspace’s runs as they change state

     A wake channel, not a log: `run` events carry a run’s identity and state so the tree can show what
    is moving. Open the per-run stream for output.

    Args:
        workspace (Union[Unset, str]):
        access_token (Union[Unset, str]):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[Union[Error, str]]
    """

    kwargs = _get_kwargs(
        workspace=workspace,
        access_token=access_token,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    *,
    client: AuthenticatedClient,
    workspace: Unset | str = UNSET,
    access_token: Unset | str = UNSET,
) -> Error | str | None:
    """The workspace’s runs as they change state

     A wake channel, not a log: `run` events carry a run’s identity and state so the tree can show what
    is moving. Open the per-run stream for output.

    Args:
        workspace (Union[Unset, str]):
        access_token (Union[Unset, str]):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Union[Error, str]
    """

    return (
        await asyncio_detailed(
            client=client,
            workspace=workspace,
            access_token=access_token,
        )
    ).parsed
