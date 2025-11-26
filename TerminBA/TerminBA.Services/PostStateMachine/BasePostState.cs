using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using Microsoft.Extensions.DependencyInjection;
using TerminBA.Services.Database;
using Mapster;
using MapsterMapper;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.PostStateMachine
{
    public class BasePostState
    {
        protected readonly IServiceProvider _serviceProvider;
        protected readonly TerminBaContext _context;
        protected readonly IMapper _mapper;

        public BasePostState(IServiceProvider serviceProvider, TerminBaContext context, IMapper mapper)
        {
            this._serviceProvider = serviceProvider;
            this._context = context;
            this._mapper = mapper;
        }


        public virtual Task<PostResponse> CreateAsync(PostInsertRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<PostResponse> UpdateAsync(int id,PostUpdateRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual  Task<bool> DeleteAsync(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<PostResponse> ReturnToPlayerSearchAsync(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<PlayRequestResponse> SendPlayRequestAsync(PlayRequestInsertRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<PlayRequestResponse> CancelAsync(int playRequestId)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<PlayRequestResponse> RespondToPlayRequestAsync(int id, bool response)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Task<PostResponse> ClosePost(Post post)
        {
            throw new UserException("Method not allowed");
        }



        public BasePostState GetPostState(string CurrentPostStateName)
        {
            switch (CurrentPostStateName)
            {
                case nameof(DraftPostState):
                    return _serviceProvider.GetService<DraftPostState>()!;
                case nameof(PlayerSearchPostState):
                    return _serviceProvider.GetService<PlayerSearchPostState>()!;
                case nameof(PlayerFoundPostState):
                    return _serviceProvider.GetService<PlayerFoundPostState>()!;
                case nameof(ClosedPostState):
                    return _serviceProvider.GetService<ClosedPostState>()!;
                default:
                    throw new UserException($"State {CurrentPostStateName} is not defined");
            }
        }
    }
}
